import 'package:flutter/material.dart';
import 'package:qfnu_app/login/login_service.dart';
import 'package:qfnu_app/shared/models.dart';
import 'package:qfnu_app/shared/widgets/glow_circle.dart';

class ExamSchedulePage extends StatefulWidget {
  final LoginService service;
  final String username;

  const ExamSchedulePage({
    super.key,
    required this.service,
    required this.username,
  });

  @override
  State<ExamSchedulePage> createState() => _ExamSchedulePageState();
}

class _ExamSchedulePageState extends State<ExamSchedulePage> {
  List<TermOption> _terms = [];
  String? _selectedTerm;
  List<ExamItem> _items = [];
  bool _loadingTerms = false;
  bool _loadingList = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTerms();
  }

  Future<void> _loadTerms() async {
    setState(() {
      _loadingTerms = true;
      _error = null;
    });

    try {
      final terms = await widget.service.fetchExamTerms();
      if (!mounted) return;

      if (terms.isEmpty) {
        setState(() {
          _terms = [];
          _selectedTerm = null;
          _error = 'No term options found.';
        });
        return;
      }

      String? defaultValue;
      for (final term in terms) {
        if (term.selected) {
          defaultValue = term.value;
          break;
        }
      }
      if (defaultValue == null) {
        if (terms.length > 1) {
          defaultValue = terms[1].value;
        } else if (terms.isNotEmpty) {
          defaultValue = terms.first.value;
        }
      }

      setState(() {
        _terms = terms;
        _selectedTerm = defaultValue;
      });

      if (defaultValue != null) {
        await _loadList(defaultValue);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load terms: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingTerms = false;
        });
      }
    }
  }

  Future<void> _loadList(String term) async {
    setState(() {
      _loadingList = true;
      _error = null;
    });

    try {
      final items = await widget.service.fetchExamList(xnxqid: term);
      if (!mounted) return;
      setState(() {
        _items = items;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load exams: $error';
        _items = [];
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingList = false;
        });
      }
    }
  }

  Widget _buildExamCard(ExamItem item, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.courseName.isEmpty ? 'Untitled course' : item.courseName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${item.courseCode} \u2022 ${item.teacher}',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.schedule, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(item.time)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(item.place)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.event_seat_outlined, size: 16),
              const SizedBox(width: 8),
              Text(item.seat.isEmpty ? '-' : item.seat),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = widget.username.trim();
    final greeting = name.isEmpty ? 'Welcome back' : 'Welcome, $name';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Schedule'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFF7F1EA),
                  Color(0xFFE6F3EE),
                  Color(0xFFF1E9DC),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          const GlowCircle(
            offset: Offset(-140, -120),
            size: 220,
            colors: [Color(0xFFBFE4D8), Color(0xFFECF6F2)],
          ),
          const GlowCircle(
            offset: Offset(200, 120),
            size: 180,
            colors: [Color(0xFFF3DCCB), Color(0xFFF7F1EA)],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_loadingTerms)
                    const LinearProgressIndicator()
                  else
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedTerm,
                            items: _terms
                                .map(
                                  (term) => DropdownMenuItem(
                                    value: term.value,
                                    child: Text(term.label),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedTerm = value;
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'Term',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          height: 50,
                          child: FilledButton.icon(
                            onPressed: _selectedTerm == null || _loadingList
                                ? null
                                : () => _loadList(_selectedTerm!),
                            icon: const Icon(Icons.search),
                            label: const Text('Query'),
                          ),
                        ),
                      ],
                    ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Expanded(
                    child: _loadingList
                        ? const Center(child: CircularProgressIndicator())
                        : _items.isEmpty
                            ? Center(
                                child: Text(
                                  'No exam data available.',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              )
                            : ListView.separated(
                                itemCount: _items.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final item = _items[index];
                                  return _buildExamCard(item, theme);
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
