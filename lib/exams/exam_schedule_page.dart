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

  String _currentTermLabel() {
    final termValue = _selectedTerm;
    if (termValue == null || termValue.isEmpty) return 'Select term';
    for (final term in _terms) {
      if (term.value == termValue) return term.label;
    }
    return termValue;
  }

  Future<void> _showTermSheet() async {
    var term = _selectedTerm;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              16 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: StatefulBuilder(
              builder: (context, setSheetState) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Select term',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close),
                            tooltip: 'Close',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_loadingTerms)
                        const LinearProgressIndicator()
                      else if (_terms.isEmpty)
                        const Text('No term options available.')
                      else
                        DropdownButtonFormField<String>(
                          value: term,
                          items: _terms
                              .map(
                                (termOption) => DropdownMenuItem(
                                  value: termOption.value,
                                  child: Text(termOption.label),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setSheetState(() {
                              term = value;
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Term',
                          ),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          const Spacer(),
                          FilledButton(
                            onPressed: _loadingTerms
                                ? null
                                : () {
                                    setState(() {
                                      _selectedTerm = term;
                                    });
                                    Navigator.of(context).pop();
                                  },
                            child: const Text('Apply'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
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
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 6)),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _ExamSummaryHeaderDelegate(
                    termLabel: _currentTermLabel(),
                    loadingTerms: _loadingTerms,
                    loadingList: _loadingList,
                    onOpenFilters: _loadingTerms ? null : _showTermSheet,
                    onQuery: _selectedTerm == null || _loadingList
                        ? null
                        : () => _loadList(_selectedTerm!),
                  ),
                ),
                if (_error != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: Text(
                        _error!,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  ),
                if (_loadingList)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_items.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        'No exam data available.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index.isOdd) {
                            return const SizedBox(height: 12);
                          }
                          final item = _items[index ~/ 2];
                          return _buildExamCard(item, theme);
                        },
                        childCount:
                            _items.isEmpty ? 0 : _items.length * 2 - 1,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExamSummaryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String termLabel;
  final bool loadingTerms;
  final bool loadingList;
  final VoidCallback? onOpenFilters;
  final VoidCallback? onQuery;

  _ExamSummaryHeaderDelegate({
    required this.termLabel,
    required this.loadingTerms,
    required this.loadingList,
    required this.onOpenFilters,
    required this.onQuery,
  });

  @override
  double get minExtent => 108;

  @override
  double get maxExtent => 108;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
      child: Card(
        elevation: 10,
        shadowColor: Colors.black26,
        color: Colors.white.withOpacity(0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      termLabel,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onOpenFilters,
                    icon: const Icon(Icons.tune),
                    tooltip: 'Filters',
                  ),
                  const SizedBox(width: 4),
                  FilledButton.icon(
                    onPressed: onQuery,
                    icon: const Icon(Icons.search),
                    label: Text(loadingList ? 'Loading' : 'Query'),
                  ),
                ],
              ),
              if (loadingTerms) ...[
                const SizedBox(height: 6),
                const LinearProgressIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _ExamSummaryHeaderDelegate oldDelegate) {
    return termLabel != oldDelegate.termLabel ||
        loadingTerms != oldDelegate.loadingTerms ||
        loadingList != oldDelegate.loadingList ||
        onOpenFilters != oldDelegate.onOpenFilters ||
        onQuery != oldDelegate.onQuery;
  }
}
