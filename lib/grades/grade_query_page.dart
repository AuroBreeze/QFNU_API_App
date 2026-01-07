import 'package:flutter/material.dart';
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
  bool _filtersExpanded = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOptions();
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

      String? defaultTerm;
      if (options.terms.length > 1) {
        defaultTerm = options.terms[1].value;
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
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load options: $error';
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
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load grades: $error';
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

  Widget _buildGradeItem(GradeItem item, ThemeData theme) {
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
            item.courseName.isEmpty ? 'Untitled course' : item.courseName,
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
              _chip('Term', item.term),
              _chip('Score', item.score),
              _chip('Credit', item.credit),
              _chip('GPA', item.gradePoint),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Grades'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadingOptions ? null : _loadOptions,
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload',
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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 10,
                    shadowColor: Colors.black26,
                    color: Colors.white.withOpacity(0.95),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Grade Query',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: _loadingOptions
                                    ? null
                                    : () {
                                        setState(() {
                                          _filtersExpanded = !_filtersExpanded;
                                        });
                                      },
                                icon: Icon(
                                  _filtersExpanded
                                      ? Icons.expand_less
                                      : Icons.tune,
                                ),
                                label: Text(
                                  _filtersExpanded ? 'Collapse' : 'Filters',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (_loadingOptions)
                            const LinearProgressIndicator()
                          else if (_filtersExpanded) ...[
                            DropdownButtonFormField<String>(
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
                            const SizedBox(height: 12),
                            if (_courseTypes.isNotEmpty) ...[
                              DropdownButtonFormField<String>(
                                initialValue: _selectedCourseType,
                                items: _courseTypes
                                    .map(
                                      (option) => DropdownMenuItem(
                                        value: option.value,
                                        child: Text(option.label),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCourseType = value;
                                  });
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Course Type',
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            TextField(
                              controller: _courseController,
                              decoration: const InputDecoration(
                                labelText: 'Course Name',
                                prefixIcon: Icon(Icons.search),
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (_displayModes.isNotEmpty) ...[
                              DropdownButtonFormField<String>(
                                initialValue: _selectedDisplayMode,
                                items: _displayModes
                                    .map(
                                      (option) => DropdownMenuItem(
                                        value: option.value,
                                        child: Text(option.label),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedDisplayMode = value;
                                  });
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Display',
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ] else ...[
                            Text(
                              _selectedTerm == null || _selectedTerm!.isEmpty
                                  ? 'Using default term'
                                  : 'Term: ${_selectedTerm!}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.black54,
                              ),
                            ),
                          ],
                          const SizedBox(height: 6),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: FilledButton.icon(
                              onPressed: _loadingOptions || _loadingList
                                  ? null
                                  : _loadGrades,
                              icon: const Icon(Icons.search),
                              label: const Text('Query'),
                            ),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              _error!,
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _loadingList
                        ? const Center(child: CircularProgressIndicator())
                        : _items.isEmpty
                            ? Center(
                                child: Text(
                                  'No grade data available.',
                                  style: theme.textTheme.bodySmall,
                                ),
                              )
                            : ListView.separated(
                                itemCount: _items.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final item = _items[index];
                                  return _buildGradeItem(item, theme);
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
