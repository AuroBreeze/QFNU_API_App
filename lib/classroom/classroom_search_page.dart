import 'package:flutter/material.dart';
import 'package:qfnu_app/l10n/app_localizations.dart';
import 'package:qfnu_app/login/login_page.dart';
import 'package:qfnu_app/login/login_service.dart';
import 'package:qfnu_app/shared/models.dart';
import 'package:qfnu_app/shared/widgets/glow_circle.dart';

class ClassroomSearchPage extends StatefulWidget {
  final LoginService service;
  final String username;

  const ClassroomSearchPage({
    super.key,
    required this.service,
    required this.username,
  });

  @override
  State<ClassroomSearchPage> createState() => _ClassroomSearchPageState();
}

class _ClassroomSearchPageState extends State<ClassroomSearchPage> {
  ClassroomQueryOptions? _options;
  ClassroomTable? _table;
  bool _loadingOptions = false;
  bool _loadingTable = false;
  String? _error;

  String? _term;
  String? _timeMode;
  String _college = '';
  String _campus = '';
  String _building = '';
  String _weekStart = '';
  String _weekEnd = '';
  String _weekdayStart = '';
  String _weekdayEnd = '';
  String _periodStart = '';
  String _periodEnd = '';
  final TextEditingController _roomController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  @override
  void dispose() {
    _roomController.dispose();
    super.dispose();
  }

  Future<void> _handleSessionExpired() async {
    await widget.service.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  String _pickSelectedValue(List<TermOption> options) {
    for (final option in options) {
      if (option.selected) return option.value;
    }
    return options.isEmpty ? '' : options.first.value;
  }

  Future<void> _loadOptions() async {
    setState(() {
      _loadingOptions = true;
      _error = null;
    });

    try {
      final options = await widget.service.fetchClassroomQueryOptions();
      if (!mounted) return;
      setState(() {
        _options = options;
        _term = options.terms.isEmpty ? null : _pickSelectedValue(options.terms);
        _timeMode = options.timeModes.isEmpty
            ? null
            : _pickSelectedValue(options.timeModes);
        _college = options.colleges.isEmpty
            ? ''
            : _pickSelectedValue(options.colleges);
        _campus = options.campuses.isEmpty
            ? ''
            : _pickSelectedValue(options.campuses);
        _building = options.buildings.isEmpty
            ? ''
            : _pickSelectedValue(options.buildings);
        _weekStart = '';
        _weekEnd = '';
        _weekdayStart = '';
        _weekdayEnd = '';
        _periodStart = '';
        _periodEnd = '';
      });

    } on SessionExpiredException {
      if (!mounted) return;
      await _handleSessionExpired();
    } catch (error) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _error = l10n.failedToLoadClassroomOptions(error.toString());
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingOptions = false;
        });
      }
    }
  }

  Future<void> _loadTable() async {
    final term = _term;
    final timeMode = _timeMode;
    if (term == null || timeMode == null) return;

    setState(() {
      _loadingTable = true;
      _error = null;
    });

    try {
      final table = await widget.service.fetchClassroomTable(
        xnxqh: term,
        kbjcmsid: timeMode,
        skyx: _college,
        xqid: _campus,
        jzwid: _building,
        skjsid: '',
        skjs: _roomController.text.trim(),
        zc1: _weekStart,
        zc2: _weekEnd,
        skxq1: _weekdayStart,
        skxq2: _weekdayEnd,
        jc1: _periodStart,
        jc2: _periodEnd,
      );
      if (!mounted) return;
      setState(() {
        _table = table;
      });
    } on SessionExpiredException {
      if (!mounted) return;
      await _handleSessionExpired();
    } catch (error) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _error = l10n.failedToLoadClassroomTable(error.toString());
        _table = null;
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingTable = false;
        });
      }
    }
  }

  Future<void> _showFilters() async {
    final options = _options;
    if (options == null) return;

    var term = _term ?? '';
    var timeMode = _timeMode ?? '';
    var college = _college;
    var campus = _campus;
    var building = _building;
    var weekStart = _weekStart;
    var weekEnd = _weekEnd;
    var weekdayStart = _weekdayStart;
    var weekdayEnd = _weekdayEnd;
    var periodStart = _periodStart;
    var periodEnd = _periodEnd;
    final roomController = TextEditingController(text: _roomController.text);
    final periodStartController = TextEditingController(text: _periodStart);
    final periodEndController = TextEditingController(text: _periodEnd);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
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
                      DropdownButtonFormField<String>(
                        value: term.isEmpty ? null : term,
                        isExpanded: true,
                        items: options.terms
                            .map(
                              (option) => DropdownMenuItem(
                                value: option.value,
                                child: Text(
                                  option.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setSheetState(() {
                            term = value ?? '';
                          });
                        },
                        decoration: InputDecoration(labelText: l10n.termLabel),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: timeMode.isEmpty ? null : timeMode,
                        isExpanded: true,
                        items: options.timeModes
                            .map(
                              (option) => DropdownMenuItem(
                                value: option.value,
                                child: Text(
                                  option.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setSheetState(() {
                            timeMode = value ?? '';
                          });
                        },
                        decoration:
                            InputDecoration(labelText: l10n.classroomTimeMode),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: college.isEmpty ? null : college,
                        isExpanded: true,
                        items: options.colleges
                            .map(
                              (option) => DropdownMenuItem(
                                value: option.value,
                                child: Text(
                                  option.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setSheetState(() {
                            college = value ?? '';
                          });
                        },
                        decoration:
                            InputDecoration(labelText: l10n.classroomCollege),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: campus.isEmpty ? null : campus,
                        isExpanded: true,
                        items: options.campuses
                            .map(
                              (option) => DropdownMenuItem(
                                value: option.value,
                                child: Text(
                                  option.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setSheetState(() {
                            campus = value ?? '';
                          });
                        },
                        decoration:
                            InputDecoration(labelText: l10n.classroomCampus),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: building.isEmpty ? null : building,
                        isExpanded: true,
                        items: options.buildings
                            .map(
                              (option) => DropdownMenuItem(
                                value: option.value,
                                child: Text(
                                  option.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setSheetState(() {
                            building = value ?? '';
                          });
                        },
                        decoration:
                            InputDecoration(labelText: l10n.classroomBuilding),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: roomController,
                        decoration:
                            InputDecoration(labelText: l10n.classroomRoom),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: weekStart.isEmpty ? null : weekStart,
                              isExpanded: true,
                              items: options.weeks
                                  .map(
                                    (option) => DropdownMenuItem(
                                      value: option.value,
                                      child: Text(
                                        option.label,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setSheetState(() {
                                  weekStart = value ?? '';
                                });
                              },
                              decoration: InputDecoration(
                                labelText: l10n.classroomWeekStart,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: weekEnd.isEmpty ? null : weekEnd,
                              isExpanded: true,
                              items: options.weeks
                                  .map(
                                    (option) => DropdownMenuItem(
                                      value: option.value,
                                      child: Text(
                                        option.label,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setSheetState(() {
                                  weekEnd = value ?? '';
                                });
                              },
                              decoration: InputDecoration(
                                labelText: l10n.classroomWeekEnd,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: weekdayStart.isEmpty ? null : weekdayStart,
                              isExpanded: true,
                              items: options.weekdays
                                  .map(
                                    (option) => DropdownMenuItem(
                                      value: option.value,
                                      child: Text(
                                        option.label,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setSheetState(() {
                                  weekdayStart = value ?? '';
                                });
                              },
                              decoration: InputDecoration(
                                labelText: l10n.classroomWeekdayStart,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: weekdayEnd.isEmpty ? null : weekdayEnd,
                              isExpanded: true,
                              items: options.weekdays
                                  .map(
                                    (option) => DropdownMenuItem(
                                      value: option.value,
                                      child: Text(
                                        option.label,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setSheetState(() {
                                  weekdayEnd = value ?? '';
                                });
                              },
                              decoration: InputDecoration(
                                labelText: l10n.classroomWeekdayEnd,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              controller: periodStartController,
                              onChanged: (value) {
                                periodStart = value.trim();
                              },
                              decoration: InputDecoration(
                                labelText: l10n.classroomPeriodStart,
                                hintText: '01',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              controller: periodEndController,
                              onChanged: (value) {
                                periodEnd = value.trim();
                              },
                              decoration: InputDecoration(
                                labelText: l10n.classroomPeriodEnd,
                                hintText: '12',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(l10n.cancel),
                          ),
                          const Spacer(),
                          FilledButton(
                            onPressed: () {
                              setState(() {
                                _term = term.isEmpty ? _term : term;
                                _timeMode = timeMode.isEmpty ? _timeMode : timeMode;
                                _college = college;
                                _campus = campus;
                                _building = building;
                                _weekStart = weekStart;
                                _weekEnd = weekEnd;
                                _weekdayStart = weekdayStart;
                                _weekdayEnd = weekdayEnd;
                                _periodStart = periodStart;
                                _periodEnd = periodEnd;
                                _roomController.text = roomController.text.trim();
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

  String _displayDayLabel(
    String raw,
    int index,
    AppLocalizations l10n,
  ) {
    if (raw.isNotEmpty) {
      if (raw.contains('\u661f\u671f\u4e00')) return l10n.weekdayMon;
      if (raw.contains('\u661f\u671f\u4e8c')) return l10n.weekdayTue;
      if (raw.contains('\u661f\u671f\u4e09')) return l10n.weekdayWed;
      if (raw.contains('\u661f\u671f\u56db')) return l10n.weekdayThu;
      if (raw.contains('\u661f\u671f\u4e94')) return l10n.weekdayFri;
      if (raw.contains('\u661f\u671f\u516d')) return l10n.weekdaySat;
      if (raw.contains('\u661f\u671f\u65e5') ||
          raw.contains('\u661f\u671f\u5929')) {
        return l10n.weekdaySun;
      }
      return raw;
    }
    switch (index) {
      case 1:
        return l10n.weekdayMon;
      case 2:
        return l10n.weekdayTue;
      case 3:
        return l10n.weekdayWed;
      case 4:
        return l10n.weekdayThu;
      case 5:
        return l10n.weekdayFri;
      case 6:
        return l10n.weekdaySat;
      case 7:
        return l10n.weekdaySun;
    }
    return l10n.weekdayMon;
  }

  Widget _buildTable(
    ClassroomTable table,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    if (table.columns.isEmpty || table.rows.isEmpty) {
      return Center(
        child: Text(
          l10n.noClassroomData,
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    final columns = [
      DataColumn(label: Text(l10n.classroomLabel)),
      ...table.columns.map((column) {
        final day = _displayDayLabel(column.dayLabel, column.dayIndex, l10n);
        final label = column.periodLabel.isEmpty
            ? day
            : '$day ${column.periodLabel}';
        return DataColumn(label: Text(label));
      }),
    ];

    final rows = table.rows.map((row) {
      final cells = [
        DataCell(Text(row.room)),
        ...row.cells.map((cell) {
          final text = cell.trim().isEmpty
              ? l10n.classroomCellEmpty
              : l10n.classroomCellOccupied;
          final color = cell.trim().isEmpty
              ? Colors.green
              : theme.colorScheme.onSurface.withOpacity(0.6);
          return DataCell(
            Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(color: color),
            ),
          );
        }),
      ];
      return DataRow(cells: cells);
    }).toList();

    return Scrollbar(
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: columns,
            rows: rows,
            headingRowColor: MaterialStatePropertyAll(
              theme.colorScheme.surfaceVariant.withOpacity(0.4),
            ),
            columnSpacing: 16,
            dataRowMinHeight: 36,
            dataRowMaxHeight: 56,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.classroomSearchTitle),
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
                  delegate: _ClassroomHeaderDelegate(
                    title: l10n.classroomSearchTitle,
                    hint: l10n.classroomFiltersHint,
                    filtersLabel: l10n.filters,
                    queryLabel: l10n.query,
                    loadingLabel: l10n.loading,
                    loading: _loadingTable,
                    onOpenFilters: _loadingOptions ? null : _showFilters,
                    onQuery:
                        _loadingTable || _term == null || _timeMode == null
                            ? null
                            : _loadTable,
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
                if (_loadingTable)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  SliverFillRemaining(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: _table == null
                          ? Center(
                              child: Text(
                                _loadingOptions
                                    ? l10n.loading
                                    : l10n.noClassroomData,
                                style: theme.textTheme.bodyMedium,
                              ),
                            )
                          : _buildTable(_table!, theme, l10n),
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

class _ClassroomHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final String hint;
  final String filtersLabel;
  final String queryLabel;
  final String loadingLabel;
  final bool loading;
  final VoidCallback? onOpenFilters;
  final VoidCallback? onQuery;

  _ClassroomHeaderDelegate({
    required this.title,
    required this.hint,
    required this.filtersLabel,
    required this.queryLabel,
    required this.loadingLabel,
    required this.loading,
    required this.onOpenFilters,
    required this.onQuery,
  });

  @override
  double get minExtent => 120;

  @override
  double get maxExtent => 120;

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
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
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
                    label: Text(loading ? loadingLabel : queryLabel),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                hint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.black54,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _ClassroomHeaderDelegate oldDelegate) {
    return title != oldDelegate.title ||
        hint != oldDelegate.hint ||
        filtersLabel != oldDelegate.filtersLabel ||
        queryLabel != oldDelegate.queryLabel ||
        loadingLabel != oldDelegate.loadingLabel ||
        loading != oldDelegate.loading ||
        onOpenFilters != oldDelegate.onOpenFilters ||
        onQuery != oldDelegate.onQuery;
  }
}
