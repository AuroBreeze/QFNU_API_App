import 'package:flutter/material.dart';
import 'package:qfnu_app/l10n/app_localizations.dart';
import 'package:qfnu_app/login/login_page.dart';
import 'package:qfnu_app/login/login_service.dart';
import 'package:qfnu_app/shared/models.dart';
import 'package:qfnu_app/shared/widgets/glow_circle.dart';

class GradeQueryPage extends StatefulWidget {
  final LoginService service;
  final String username;

  const GradeQueryPage({
    super.key,
    required this.service,
    required this.username,
  });

  @override
  State<GradeQueryPage> createState() => _GradeQueryPageState();
}

class _GradeQueryPageState extends State<GradeQueryPage> {
  final _courseController = TextEditingController();
  List<TermOption> _terms = [];
  List<TermOption> _courseTypes = [];
  List<TermOption> _displayModes = [];
  String? _selectedTerm;
  String? _selectedCourseType;
  String? _selectedDisplayMode;
  List<GradeItem> _items = [];
  bool _loadingOptions = false;
  bool _loadingList = false;
  bool _autoQueried = false;
  String? _error;

  double? _parseNumber(String value) {
    final match = RegExp(r'[-+]?\d*\.?\d+').firstMatch(value);
    if (match == null) return null;
    return double.tryParse(match.group(0) ?? '');
  }

  double? _averageGpa() {
    double weightedSum = 0;
    double creditSum = 0;
    double plainSum = 0;
    int plainCount = 0;

    for (final item in _items) {
      final gpa = _parseNumber(item.gradePoint);
      if (gpa == null) continue;
      final credit = _parseNumber(item.credit);
      if (credit != null && credit > 0) {
        weightedSum += gpa * credit;
        creditSum += credit;
      } else {
        plainSum += gpa;
        plainCount += 1;
      }
    }

    if (creditSum > 0) {
      return weightedSum / creditSum;
    }
    if (plainCount > 0) {
      return plainSum / plainCount;
    }
    return null;
  }

  String _currentTermLabel(AppLocalizations l10n) {
    final termValue = _selectedTerm;
    if (termValue == null || termValue.isEmpty) return l10n.allTerms;
    for (final term in _terms) {
      if (term.value == termValue) return term.label;
    }
    return termValue;
  }

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  Future<void> _handleSessionExpired() async {
    await widget.service.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _courseController.dispose();
    super.dispose();
  }

  Future<void> _loadOptions() async {
    setState(() {
      _loadingOptions = true;
      _error = null;
    });

    try {
      final options = await widget.service.fetchGradeQueryOptions();
      if (!mounted) return;

      final nonEmptyTerms =
          options.terms.where((option) => option.value.isNotEmpty).toList();
      String? defaultTerm;
      if (nonEmptyTerms.length > 1) {
        defaultTerm = nonEmptyTerms[1].value;
      } else if (nonEmptyTerms.isNotEmpty) {
        defaultTerm = nonEmptyTerms.first.value;
      } else if (options.terms.isNotEmpty) {
        defaultTerm = options.terms.first.value;
      }

      String? defaultCourseType;
      for (final option in options.courseTypes) {
        if (option.value.isEmpty) {
          defaultCourseType = option.value;
          break;
        }
      }
      defaultCourseType ??=
          options.courseTypes.isNotEmpty ? options.courseTypes.first.value : null;

      String? defaultDisplayMode = 'all';
      if (!options.displayModes.any((option) => option.value == 'all')) {
        for (final option in options.displayModes) {
          if (option.selected) {
            defaultDisplayMode = option.value;
            break;
          }
        }
        if (options.displayModes.isNotEmpty && defaultDisplayMode == 'all') {
          defaultDisplayMode = options.displayModes.first.value;
        }
      }

      setState(() {
        _terms = options.terms;
        _courseTypes = options.courseTypes;
        _displayModes = options.displayModes;
        _selectedTerm = defaultTerm;
        _selectedCourseType = defaultCourseType;
        _selectedDisplayMode = defaultDisplayMode;
      });
      if (!_autoQueried) {
        _autoQueried = true;
        await _loadGrades();
      }
    } on SessionExpiredException {
      if (!mounted) return;
      await _handleSessionExpired();
    } catch (error) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _error = l10n.failedToLoadOptions(error.toString());
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingOptions = false;
        });
      }
    }
  }

  Future<void> _loadGrades() async {
    setState(() {
      _loadingList = true;
      _error = null;
    });

    try {
      final items = await widget.service.fetchGrades(
        kksj: _selectedTerm ?? '',
        kcxz: _selectedCourseType ?? '',
        kcmc: _courseController.text.trim(),
        xsfs: _selectedDisplayMode ?? 'all',
      );
      if (!mounted) return;
      setState(() {
        _items = items;
      });
    } on SessionExpiredException {
      if (!mounted) return;
      await _handleSessionExpired();
    } catch (error) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _error = l10n.failedToLoadGrades(error.toString());
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

  Widget _buildGradeItem(
    GradeItem item,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.courseName.isEmpty ? l10n.untitledCourse : item.courseName,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.courseCode,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 6,
            children: [
              _chip(l10n.termLabel, item.term),
              _chip(l10n.scoreLabel, item.score),
              _chip(l10n.creditLabel, item.credit),
              _chip(l10n.gpaLabel, item.gradePoint),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, String value) {
    final text = value.isEmpty ? '-' : value;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $text',
        style: const TextStyle(fontSize: 11, color: Colors.black87),
      ),
    );
  }

  Widget _buildFiltersFields({
    required AppLocalizations l10n,
    required String? selectedTerm,
    required ValueChanged<String?> onTermChanged,
    required String? selectedCourseType,
    required ValueChanged<String?> onCourseTypeChanged,
    required String? selectedDisplayMode,
    required ValueChanged<String?> onDisplayModeChanged,
  }) {
    if (_loadingOptions) {
      return const LinearProgressIndicator();
    }

    String optionLabel(TermOption option, {bool isTerm = false}) {
      final isAllValue = option.value.isEmpty || option.value == 'all';
      final isAllLabel = option.label.toLowerCase() == 'all';
      if (isAllValue || isAllLabel) {
        return isTerm ? l10n.allTerms : l10n.allOption;
      }
      return option.label;
    }

    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: selectedTerm,
          items: _terms
              .map(
                (term) => DropdownMenuItem(
                  value: term.value,
                  child: Text(optionLabel(term, isTerm: true)),
                ),
              )
              .toList(),
          onChanged: onTermChanged,
          decoration: InputDecoration(
            labelText: l10n.termLabel,
          ),
        ),
        const SizedBox(height: 12),
        if (_courseTypes.isNotEmpty) ...[
          DropdownButtonFormField<String>(
            value: selectedCourseType,
            items: _courseTypes
                .map(
                  (option) => DropdownMenuItem(
                    value: option.value,
                    child: Text(optionLabel(option)),
                  ),
                )
                .toList(),
            onChanged: onCourseTypeChanged,
            decoration: InputDecoration(
              labelText: l10n.courseTypeLabel,
            ),
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: _courseController,
          decoration: InputDecoration(
            labelText: l10n.courseNameLabel,
            prefixIcon: const Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 12),
        if (_displayModes.isNotEmpty) ...[
          DropdownButtonFormField<String>(
            value: selectedDisplayMode,
            items: _displayModes
                .map(
                  (option) => DropdownMenuItem(
                    value: option.value,
                    child: Text(optionLabel(option)),
                  ),
                )
                .toList(),
            onChanged: onDisplayModeChanged,
            decoration: InputDecoration(
              labelText: l10n.displayLabel,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Future<void> _showFiltersSheet() async {
    var term = _selectedTerm;
    var courseType = _selectedCourseType;
    var displayMode = _selectedDisplayMode;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final theme = Theme.of(context);
        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
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
                            l10n.filters,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close),
                            tooltip: l10n.close,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildFiltersFields(
                        l10n: l10n,
                        selectedTerm: term,
                        onTermChanged: (value) {
                          setSheetState(() {
                            term = value;
                          });
                        },
                        selectedCourseType: courseType,
                        onCourseTypeChanged: (value) {
                          setSheetState(() {
                            courseType = value;
                          });
                        },
                        selectedDisplayMode: displayMode,
                        onDisplayModeChanged: (value) {
                          setSheetState(() {
                            displayMode = value;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(l10n.cancel),
                          ),
                          const Spacer(),
                          FilledButton(
                            onPressed: _loadingOptions
                                ? null
                                : () {
                                    setState(() {
                                      _selectedTerm = term;
                                      _selectedCourseType = courseType;
                                      _selectedDisplayMode = displayMode;
                                    });
                                    Navigator.of(context).pop();
                                  },
                            child: Text(l10n.apply),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.gradeQueryTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadingOptions ? null : _loadOptions,
            icon: const Icon(Icons.refresh),
            tooltip: l10n.reload,
          ),
        ],
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
                  delegate: _GradeSummaryHeaderDelegate(
                    termLabel: _currentTermLabel(l10n),
                    averageGpa: _averageGpa(),
                    loadingOptions: _loadingOptions,
                    loadingList: _loadingList,
                    currentTermLabel: l10n.currentTermLabel,
                    filtersLabel: l10n.filters,
                    queryLabel: l10n.query,
                    loadingLabel: l10n.loading,
                    averageGpaLabel: l10n.averageGpaValue,
                    onOpenFilters: _loadingOptions ? null : _showFiltersSheet,
                    onQuery:
                        _loadingOptions || _loadingList ? null : _loadGrades,
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
                        l10n.noGradeData,
                        style: theme.textTheme.bodySmall,
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
                          return _buildGradeItem(item, theme, l10n);
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

class _GradeSummaryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String termLabel;
  final double? averageGpa;
  final bool loadingOptions;
  final bool loadingList;
  final String currentTermLabel;
  final String filtersLabel;
  final String queryLabel;
  final String loadingLabel;
  final String Function(Object value) averageGpaLabel;
  final VoidCallback? onOpenFilters;
  final VoidCallback? onQuery;

  _GradeSummaryHeaderDelegate({
    required this.termLabel,
    required this.averageGpa,
    required this.loadingOptions,
    required this.loadingList,
    required this.currentTermLabel,
    required this.filtersLabel,
    required this.queryLabel,
    required this.loadingLabel,
    required this.averageGpaLabel,
    required this.onOpenFilters,
    required this.onQuery,
  });

  @override
  double get minExtent => 124;

  @override
  double get maxExtent => 124;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);
    final gpaText = averageGpa == null ? '--' : averageGpa!.toStringAsFixed(2);

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentTermLabel,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          termLabel,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onOpenFilters,
                    icon: const Icon(Icons.tune),
                    tooltip: filtersLabel,
                  ),
                  const SizedBox(width: 4),
                  FilledButton.icon(
                    onPressed: onQuery,
                    icon: const Icon(Icons.search),
                    label: Text(loadingList ? loadingLabel : queryLabel),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                averageGpaLabel(gpaText),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (loadingOptions) ...[
                const SizedBox(height: 8),
                const LinearProgressIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _GradeSummaryHeaderDelegate oldDelegate) {
    return termLabel != oldDelegate.termLabel ||
        averageGpa != oldDelegate.averageGpa ||
        loadingOptions != oldDelegate.loadingOptions ||
        loadingList != oldDelegate.loadingList ||
        currentTermLabel != oldDelegate.currentTermLabel ||
        filtersLabel != oldDelegate.filtersLabel ||
        queryLabel != oldDelegate.queryLabel ||
        loadingLabel != oldDelegate.loadingLabel ||
        averageGpaLabel != oldDelegate.averageGpaLabel ||
        onOpenFilters != oldDelegate.onOpenFilters ||
        onQuery != oldDelegate.onQuery;
  }
}
