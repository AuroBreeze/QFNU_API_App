import base64
import json
import secrets
import time
import re
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import parse_qs, urlparse

import requests

BASE_URL = "http://zhjw.qfnu.edu.cn"
MAIN_URL = f"{BASE_URL}/jsxsd/framework/xsMain.jsp"
CAPTCHA_URL = f"{BASE_URL}/jsxsd/verifycode.servlet"
LOGIN_URL = f"{BASE_URL}/jsxsd/xk/LoginToXkLdap"
QUERY_URL = f"{BASE_URL}/jsxsd/xsks/xsksap_query"
LIST_URL = f"{BASE_URL}/jsxsd/xsks/xsksap_list"
SCHEDULE_URL = f"{BASE_URL}/jsxsd/framework/main_index_loadkb.jsp"
GRADE_QUERY_URL = f"{BASE_URL}/jsxsd/kscj/cjcx_query"
GRADE_LIST_URL = f"{BASE_URL}/jsxsd/kscj/cjcx_list"

SESSION_TTL_SECONDS = 15 * 60
SESSIONS = {}
ALERT_RE = re.compile(r"alert\((['\"])(.*?)\1\)", re.IGNORECASE | re.DOTALL)


def _now():
    return time.time()


def _log(message):
    timestamp = time.strftime("%Y-%m-%d %H:%M:%S")
    print(f"[{timestamp}] {message}", flush=True)


def _extract_alert(text):
    if not text:
        return None
    match = ALERT_RE.search(text)
    if not match:
        return None
    message = match.group(2)
    message = (
        message.replace("\\r", "\r")
        .replace("\\n", "\n")
        .replace("\\t", "\t")
        .replace('\\"', '"')
        .replace("\\'", "'")
    )
    message = message.strip()
    return message or None


def _decode_response(response):
    encoding = response.encoding or response.apparent_encoding or "utf-8"
    response.encoding = encoding
    return response.text


def _is_login_success(text, response=None):
    if not text:
        text = ""
    if "xsMain.jsp" in text:
        return True
    if response is None:
        return False
    final_url = getattr(response, "url", "")
    if final_url and "xsMain.jsp" in final_url:
        return True
    history = getattr(response, "history", []) or []
    for item in history:
        if "xsMain.jsp" in getattr(item, "url", ""):
            return True
        location = item.headers.get("Location") if hasattr(item, "headers") else None
        if location and "xsMain.jsp" in location:
            return True
    return False


class SessionState:
    def __init__(self):
        self.session = requests.Session()
        self.session.headers.update(
            {
                "User-Agent": (
                    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
                    "AppleWebKit/537.36 (KHTML, like Gecko) "
                    "Chrome/120.0.0.0 Safari/537.36"
                )
            }
        )
        self.last_used = _now()
        self.session.get(MAIN_URL, timeout=10)

    def touch(self):
        self.last_used = _now()


def _cleanup_sessions():
    cutoff = _now() - SESSION_TTL_SECONDS
    stale = [sid for sid, state in SESSIONS.items() if state.last_used < cutoff]
    for sid in stale:
        SESSIONS.pop(sid, None)


def _create_session():
    state = SessionState()
    sid = secrets.token_urlsafe(16)
    SESSIONS[sid] = state
    return sid


def _get_session(session_id):
    state = SESSIONS.get(session_id)
    if not state:
        return None
    if _now() - state.last_used > SESSION_TTL_SECONDS:
        SESSIONS.pop(session_id, None)
        return None
    state.touch()
    return state


class ProxyHandler(BaseHTTPRequestHandler):
    def _set_cors(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type, X-Session-Id")

    def _send_json(self, status, payload):
        data = json.dumps(payload).encode("utf-8")
        self.send_response(status)
        self._set_cors()
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def _send_text(self, status, payload, content_type="text/html; charset=utf-8"):
        data = payload.encode("utf-8", errors="replace")
        self.send_response(status)
        self._set_cors()
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def _send_bytes(self, status, payload, content_type):
        self.send_response(status)
        self._set_cors()
        self.send_header("Content-Type", content_type)
        self.send_header("Cache-Control", "no-store")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def _parse_json(self):
        try:
            length = int(self.headers.get("Content-Length", 0))
        except ValueError:
            return None, "Invalid Content-Length"

        raw_body = self.rfile.read(length) if length > 0 else b""
        if not raw_body:
            return {}, None
        try:
            return json.loads(raw_body.decode("utf-8")), None
        except json.JSONDecodeError:
            return None, "Invalid JSON"

    def do_OPTIONS(self):
        self.send_response(204)
        self._set_cors()
        self.end_headers()

    def do_GET(self):
        _cleanup_sessions()
        parsed = urlparse(self.path)
        _log(f"GET {parsed.path} from {self.client_address[0]}")

        if parsed.path == "/session":
            try:
                session_id = _create_session()
            except requests.RequestException as exc:
                _log(f"session create failed: {exc}")
                self._send_json(502, {"error": "Failed to create session", "detail": str(exc)})
                return
            _log(f"session created sid={session_id[:8]}...")
            self._send_json(200, {"sessionId": session_id})
            return

        if parsed.path == "/captcha":
            params = parse_qs(parsed.query)
            session_id = None
            if "sid" in params:
                session_id = params["sid"][0]
            if not session_id:
                session_id = self.headers.get("X-Session-Id")

            if not session_id:
                _log("captcha missing session id")
                self._send_json(400, {"error": "Missing sessionId"})
                return

            state = _get_session(session_id)
            if not state:
                _log(f"captcha session expired sid={session_id[:8]}...")
                self._send_json(404, {"error": "Session expired"})
                return

            try:
                response = state.session.get(CAPTCHA_URL, timeout=10)
            except requests.RequestException as exc:
                _log(f"captcha fetch failed: {exc}")
                self._send_json(502, {"error": "Captcha fetch failed", "detail": str(exc)})
                return

            content_type = response.headers.get("Content-Type", "image/jpeg")
            _log(f"captcha ok sid={session_id[:8]}... bytes={len(response.content)}")
            self._send_bytes(200, response.content, content_type)
            return

        if parsed.path == "/xsks/query":
            params = parse_qs(parsed.query)
            session_id = None
            if "sid" in params:
                session_id = params["sid"][0]
            if not session_id:
                session_id = self.headers.get("X-Session-Id")

            if not session_id:
                _log("xsks query missing session id")
                self._send_json(400, {"error": "Missing sessionId"})
                return

            state = _get_session(session_id)
            if not state:
                _log(f"xsks query session expired sid={session_id[:8]}...")
                self._send_json(404, {"error": "Session expired"})
                return

            try:
                response = state.session.get(QUERY_URL, timeout=10)
            except requests.RequestException as exc:
                _log(f"xsks query failed: {exc}")
                self._send_json(502, {"error": "Query fetch failed", "detail": str(exc)})
                return

            html = _decode_response(response)
            _log(f"xsks query ok sid={session_id[:8]}... len={len(html)}")
            self._send_text(200, html)
            return

        if parsed.path == "/kscj/query":
            params = parse_qs(parsed.query)
            session_id = None
            if "sid" in params:
                session_id = params["sid"][0]
            if not session_id:
                session_id = self.headers.get("X-Session-Id")

            if not session_id:
                _log("kscj query missing session id")
                self._send_json(400, {"error": "Missing sessionId"})
                return

            state = _get_session(session_id)
            if not state:
                _log(f"kscj query session expired sid={session_id[:8]}...")
                self._send_json(404, {"error": "Session expired"})
                return

            try:
                response = state.session.get(GRADE_QUERY_URL, timeout=10)
            except requests.RequestException as exc:
                _log(f"kscj query failed: {exc}")
                self._send_json(502, {"error": "Query fetch failed", "detail": str(exc)})
                return

            html = _decode_response(response)
            _log(f"kscj query ok sid={session_id[:8]}... len={len(html)}")
            self._send_text(200, html)
            return

        _log(f"unknown path: {parsed.path}")
        self._send_json(404, {"error": "Not found"})

    def do_POST(self):
        _cleanup_sessions()
        if self.path == "/kb/day":
            _log(f"POST /kb/day from {self.client_address[0]}")
            payload, error = self._parse_json()
            if error:
                _log(f"kb day bad request: {error}")
                self._send_json(400, {"error": error})
                return

            session_id = str(payload.get("sessionId", "")).strip()
            rq = str(payload.get("rq", "")).strip()

            if not session_id:
                _log("kb day missing session id")
                self._send_json(400, {"error": "Missing sessionId"})
                return
            if not rq:
                _log("kb day missing rq")
                self._send_json(400, {"error": "Missing rq"})
                return

            state = _get_session(session_id)
            if not state:
                _log(f"kb day session expired sid={session_id[:8]}...")
                self._send_json(404, {"error": "Session expired"})
                return

            try:
                response = state.session.post(SCHEDULE_URL, data={"rq": rq}, timeout=10)
            except requests.RequestException as exc:
                _log(f"kb day request failed: {exc}")
                self._send_json(502, {"error": "Schedule request failed", "detail": str(exc)})
                return

            html = _decode_response(response)
            _log(f"kb day ok sid={session_id[:8]}... len={len(html)} rq={rq}")
            self._send_text(200, html)
            return

        if self.path == "/xsks/list":
            _log(f"POST /xsks/list from {self.client_address[0]}")
            payload, error = self._parse_json()
            if error:
                _log(f"xsks list bad request: {error}")
                self._send_json(400, {"error": error})
                return

            session_id = str(payload.get("sessionId", "")).strip()
            xnxqid = str(payload.get("xnxqid", "")).strip()
            xqlb = str(payload.get("xqlb", "")).strip()

            if not session_id:
                _log("xsks list missing session id")
                self._send_json(400, {"error": "Missing sessionId"})
                return
            if not xnxqid:
                _log("xsks list missing xnxqid")
                self._send_json(400, {"error": "Missing xnxqid"})
                return

            state = _get_session(session_id)
            if not state:
                _log(f"xsks list session expired sid={session_id[:8]}...")
                self._send_json(404, {"error": "Session expired"})
                return

            data = {
                "xqlbmc": "",
                "sxxnxq": "",
                "dqxnxq": "",
                "ckbz": "",
                "xnxqid": xnxqid,
                "xqlb": xqlb,
            }

            try:
                response = state.session.post(LIST_URL, data=data, timeout=10)
            except requests.RequestException as exc:
                _log(f"xsks list request failed: {exc}")
                self._send_json(502, {"error": "List request failed", "detail": str(exc)})
                return

            html = _decode_response(response)
            _log(
                f"xsks list ok sid={session_id[:8]}... len={len(html)} xnxqid={xnxqid}"
            )
            self._send_text(200, html)
            return

        if self.path == "/kscj/list":
            _log(f"POST /kscj/list from {self.client_address[0]}")
            payload, error = self._parse_json()
            if error:
                _log(f"kscj list bad request: {error}")
                self._send_json(400, {"error": error})
                return

            session_id = str(payload.get("sessionId", "")).strip()
            kksj = str(payload.get("kksj", "")).strip()
            kcxz = str(payload.get("kcxz", "")).strip()
            kcmc = str(payload.get("kcmc", "")).strip()
            xsfs = str(payload.get("xsfs", "")).strip()

            if not session_id:
                _log("kscj list missing session id")
                self._send_json(400, {"error": "Missing sessionId"})
                return

            state = _get_session(session_id)
            if not state:
                _log(f"kscj list session expired sid={session_id[:8]}...")
                self._send_json(404, {"error": "Session expired"})
                return

            data = {
                "kksj": kksj,
                "kcxz": kcxz,
                "kcmc": kcmc,
                "xsfs": xsfs,
            }

            try:
                response = state.session.post(GRADE_LIST_URL, data=data, timeout=10)
            except requests.RequestException as exc:
                _log(f"kscj list request failed: {exc}")
                self._send_json(502, {"error": "List request failed", "detail": str(exc)})
                return

            html = _decode_response(response)
            _log(f"kscj list ok sid={session_id[:8]}... len={len(html)}")
            self._send_text(200, html)
            return

        if self.path != "/login":
            _log(f"POST {self.path} from {self.client_address[0]} (not found)")
            self._send_json(404, {"error": "Not found"})
            return

        _log(f"POST /login from {self.client_address[0]}")
        payload, error = self._parse_json()
        if error:
            _log(f"login bad request: {error}")
            self._send_json(400, {"error": error})
            return

        session_id = str(payload.get("sessionId", "")).strip()
        username = str(payload.get("username", "")).strip()
        password = str(payload.get("password", ""))
        captcha = str(payload.get("captcha", "")).strip()

        if not session_id:
            _log("login missing session id")
            self._send_json(400, {"error": "Missing sessionId"})
            return
        if not username or not password or not captcha:
            _log("login missing username/password/captcha")
            self._send_json(400, {"error": "Missing username, password, or captcha"})
            return

        state = _get_session(session_id)
        if not state:
            _log(f"login session expired sid={session_id[:8]}...")
            self._send_json(404, {"error": "Session expired"})
            return

        encoded = (
            base64.b64encode(username.encode("utf-8")).decode("utf-8")
            + "%%%"
            + base64.b64encode(password.encode("utf-8")).decode("utf-8")
        )

        try:
            response = state.session.post(
                LOGIN_URL,
                data={
                    "userAccount": "",
                    "userPassword": "",
                    "RANDOMCODE": captcha,
                    "encoded": encoded,
                },
                timeout=10,
            )
        except requests.RequestException as exc:
            _log(f"login request failed: {exc}")
            self._send_json(502, {"error": "Login request failed", "detail": str(exc)})
            return

        raw = response.text
        alert = _extract_alert(raw)
        ok = _is_login_success(raw, response)
        final_url = getattr(response, "url", "")
        _log(
            "login ok=%s sid=%s... len=%s alert=%r url=%s"
            % (ok, session_id[:8], len(raw), alert, final_url)
        )
        self._send_json(
            200,
            {"ok": ok, "raw": raw, "alert": alert, "finalUrl": final_url},
        )

    def log_message(self, format, *args):
        return


def run(host="0.0.0.0", port=8080):
    server = HTTPServer((host, port), ProxyHandler)
    print(f"Proxy listening on http://{host}:{port}")
    server.serve_forever()


if __name__ == "__main__":
    run()
