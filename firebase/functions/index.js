const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');
const cheerio = require('cheerio');

admin.initializeApp();

const db = admin.firestore();
const GRADE_LIST_URL = 'http://zhjw.qfnu.edu.cn/jsxsd/kscj/cjcx_list';

function looksLikeLoginPage(html) {
  if (!html) return true;
  if (/LoginToXkLdap/i.test(html)) return true;
  const hasUser = /name\s*=\s*['"]userAccount['"]/i.test(html);
  const hasCaptcha = /name\s*=\s*['"]RANDOMCODE['"]/i.test(html);
  return hasUser && hasCaptcha;
}

function parseGradeSignatures(html) {
  const $ = cheerio.load(html);
  const signatures = [];
  const rows = $('#dataList tr').toArray();
  for (const row of rows) {
    const cells = $(row).find('td');
    if (cells.length < 6) continue;
    const courseCode = $(cells[2]).text().trim();
    const score = $(cells[5]).text().trim();
    if (!courseCode || !score) continue;
    signatures.push(`${courseCode}|${score}`);
  }
  return signatures;
}

async function fetchGradeList(cookies) {
  const body = new URLSearchParams({
    kksj: '',
    kcxz: '',
    kcmc: '',
    xsfs: 'all',
  }).toString();

  const response = await axios.post(GRADE_LIST_URL, body, {
    headers: {
      Cookie: cookies.join('; '),
      'Content-Type': 'application/x-www-form-urlencoded',
      'User-Agent': 'Mozilla/5.0',
    },
    timeout: 15000,
  });

  return response.data || '';
}

exports.registerSession = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }
  const { username, token, cookies, platform } = req.body || {};
  if (!username || !token || !Array.isArray(cookies) || cookies.length === 0) {
    res.status(400).json({ error: 'Missing username, token, or cookies' });
    return;
  }

  await db.collection('grade_sessions').doc(String(username)).set(
    {
      token: String(token),
      cookies,
      platform: platform || 'unknown',
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true }
  );

  res.json({ ok: true });
});

exports.unregisterToken = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }
  const { token } = req.body || {};
  if (!token) {
    res.status(400).json({ error: 'Missing token' });
    return;
  }

  const snapshot = await db
    .collection('grade_sessions')
    .where('token', '==', String(token))
    .get();
  const batch = db.batch();
  snapshot.forEach((doc) => batch.update(doc.ref, { token: null }));
  await batch.commit();

  res.json({ ok: true });
});

exports.checkGrades = functions.pubsub.schedule('every 6 hours').onRun(async () => {
  const snapshot = await db.collection('grade_sessions').get();
  for (const doc of snapshot.docs) {
    const data = doc.data() || {};
    const token = data.token;
    const cookies = Array.isArray(data.cookies) ? data.cookies : [];
    if (!token || cookies.length === 0) continue;

    let html = '';
    try {
      html = await fetchGradeList(cookies);
    } catch (error) {
      functions.logger.warn('fetch grade list failed', doc.id, error);
      continue;
    }

    if (looksLikeLoginPage(html)) {
      await db.collection('grade_sessions').doc(doc.id).update({
        sessionExpiredAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      await admin.messaging().send({
        token,
        notification: {
          title: 'Session expired',
          body: 'Please open the app to refresh your session.',
        },
        data: { type: 'session_expired' },
      });
      continue;
    }

    const signatures = parseGradeSignatures(html);
    if (signatures.length === 0) continue;

    const previous = Array.isArray(data.signatures) ? data.signatures : [];
    const previousSet = new Set(previous);
    const newItems = signatures.filter((value) => !previousSet.has(value));

    if (newItems.length > 0) {
      await admin.messaging().send({
        token,
        notification: {
          title: 'New grades available',
          body: `${newItems.length} new grade(s) detected`,
        },
        android: {
          notification: {
            channelId: 'grade_updates',
          },
        },
        data: { type: 'grade_update', count: String(newItems.length) },
      });
    }

    await db.collection('grade_sessions').doc(doc.id).update({
      signatures,
      lastCheckedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }
  return null;
});
