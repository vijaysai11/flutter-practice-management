import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:practice_management/constants/app_constants.dart';
import 'package:practice_management/constants/config.dart';
import 'package:practice_management/pages/summary-display-card.dart';
import 'dart:convert';

import 'package:practice_management/services/api_service.dart';

class SummarySection extends StatefulWidget {
  const SummarySection({super.key});

  @override
  _SummarySectionState createState() => _SummarySectionState();
}

class _SummarySectionState extends State<SummarySection> {
  String? _selectedOption;
  String? _selectedSummaryOption;
  String? _selectedPractice;
  List<String> selectedBreadcrumbs = ['Practice Group'];
  List<dynamic> _practices = [];
  List<dynamic> _employees = [];
  final List<String> tabLabels = AppConstants.tabLabels;
  bool isLoading = false;
  bool _showSummaryDetailPage = false;
  List<Map<String, Object>> summaryData = [];
  List<Map<String, dynamic>> result = [];
  Map<String, double> practiceResourceSummary = {};
  String? _popupMenuSelection;
  final apiService = ApiService(baseUrl: Config.baseUrl);
  dynamic data;


  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
      try {
    //  data = await apiService.get('', token: Config.token);
     final String response = await rootBundle.loadString('assets/data.json');
     data = json.decode(response);
    setState(() {
      _practices = [
        {'practiceId': '0', 'practiceName': 'All Practices'},
        ...data['employeePractices']
      ];

      _selectedOption ??= '0';
    });
    _assignSummaryOption();
  } catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );  }

  }

  void _assignSummaryOption() async {
    setState(() {
      isLoading = true;
      _showSummaryDetailPage = false;
      practiceResourceSummary = {};
      result = [];
    });


    final List<dynamic> activeProjects = [];
    final List<String> summaryOptions = [];
    final Map<String, Map<String, List<dynamic>>> groupedEmployees = {};


    if (_selectedOption == null) return;

    final allEmployees = _getAllEmployees(data);

    _groupEmployeesByProjectStatus(
        allEmployees, activeProjects, groupedEmployees, summaryOptions);

    setState(() {
      _selectedPractice = _selectedOption;
      _employees = _processGroupedEmployees(groupedEmployees, summaryOptions);
      _selectedSummaryOption = summaryOptions.first;
    });

  
    result = _calculateAllocations(activeProjects, summaryOptions);

    _calculatePracticeResourceSummary(result);

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  List<dynamic> _getAllEmployees(Map<String, dynamic> data) {
    if (_selectedOption == '0') {
      return data['data'].expand((practice) {
        final resources = practice['projectResourcesData'];
        return resources is Iterable ? resources : [];
      }).toList();
    } else {
      return (data['data'].firstWhere(
                (element) =>
                    element['practiceId'].toString() == _selectedOption,
                orElse: () => null,
              )?['projectResourcesData'] ??
              [])
          .toList();
    }
  }

  void _groupEmployeesByProjectStatus(
      List<dynamic> allEmployees,
      List<dynamic> activeProjects,
      Map<String, Map<String, List<dynamic>>> groupedEmployees,
      List<String> summaryOptions) {
    allEmployees.forEach((employee) {
      final endDate = employee['endDate'];
      final startDate = employee['startDate'];

      final endDateTime = endDate != null ? DateTime.tryParse(endDate) : null;
      final startDateTime =
          startDate != null ? DateTime.tryParse(startDate) : null;

      final isEndDateValid =
          endDateTime == null || endDateTime.isAfter(DateTime.now());
      final isStartDateValid =
          startDateTime != null && startDateTime.isBefore(DateTime.now());

      if (isEndDateValid && isStartDateValid) {
        activeProjects.add(employee);
      }

      final projectType =
          isEndDateValid ? 'activeProjects' : 'previousProjects';
      final employeeName = employee['employeeName'];

      if (employeeName != null) {
        if (!groupedEmployees.containsKey(employeeName)) {
          groupedEmployees[employeeName] = {
            'activeProjects': [],
            'previousProjects': []
          };
        }
        groupedEmployees[employeeName]?[projectType]?.add(employee);
      }
    });
  }

  List<Map<String, dynamic>> _processGroupedEmployees(
      Map<String, Map<String, List<dynamic>>> groupedEmployees,
      List<String> summaryOptions) {
    return groupedEmployees.entries.map((entry) {
      List<Map<String, dynamic>> filteredActiveProjects =
          (entry.value['activeProjects'] as List)
              .where((project) {
                final statusValue = project['projectResourceStatusValue'];
                if (summaryOptions.contains(statusValue)) {
                  return false;
                }
                summaryOptions.add(statusValue);
                return true;
              })
              .cast<Map<String, dynamic>>()
              .toList();

      return {
        'employeeName': entry.key,
        'activeProjects': filteredActiveProjects,
        'previousProjects': entry.value['previousProjects'],
      };
    }).toList();
  }

  List<Map<String, dynamic>> _calculateAllocations(
      List<dynamic> activeProjects, List<String> summaryOptions) {
    const designations = AppConstants.designations;

    final designationMap = {
      for (var d in designations) d['fullName']!.toLowerCase(): d['name']
    };

    return summaryOptions.map((option) {
      final billable = activeProjects
          .where((project) =>
              project['projectResourceStatusValue'] == option &&
              project['billable'] == true)
          .toList();

      final reserved = activeProjects
          .where((project) =>
              project['projectResourceStatusValue'] == option &&
              project['projectName'] != 'RESOURCE POOL' &&
              (project['billableAllocation'] == 0 ||
                  !project.containsKey('billableAllocation')) &&
              project['billable'] != true)
          .toList();

      final resourcePool = activeProjects
          .where((project) =>
              project['projectResourceStatusValue'] == option &&
              project['projectName'] == 'RESOURCE POOL' &&
              option != 'Required In Project')
          .toList();

      Map<String, double> calculateAllocations(List projects) {
        final allocations = {
          for (var d in designations) d['name'] as String: 0.0
        };

        for (final project in projects) {
          final fullName = project['designation'] as String?;
          final designation =
              fullName != null ? designationMap[fullName.toLowerCase()] : null;
          final allocation =
              ((project['projectAllocation'] ?? 0) as int) / 100.0;

          if (designation != null) {
            allocations[designation] =
                (allocations[designation] ?? 0.0) + allocation;
          }
        }

        allocations.updateAll((key, value) {
          return (value * 100).roundToDouble() / 100;
        });

        return allocations;
      }

      Map<String, double> calculateTotalAllocations() {
        final totalAllocations = <String, double>{};

        final allAllocations = {
          'Billable': calculateAllocations(billable),
          'Reserved': calculateAllocations(reserved),
          'Resource Pool': calculateAllocations(resourcePool),
        };

        for (var designation in designationMap.values) {
          totalAllocations[designation ?? ''] = 0.0;
          allAllocations.forEach((category, allocations) {
            if (designation != null) {
              totalAllocations[designation] =
                  (totalAllocations[designation] ?? 0.0) +
                      (allocations[designation] ?? 0.0);
            }
          });
        }

        return totalAllocations;
      }

      final totalAllocations = calculateTotalAllocations();
      double total = totalAllocations.values
          .fold(0.0, (sum, allocation) => sum + allocation);

      return {
        'option': option,
        if (billable.isNotEmpty)
          'Billable': {
            'employees': billable,
            'allocations': calculateAllocations(billable)
          },
        if (resourcePool.isNotEmpty)
          'Resource Pool': {
            'employees': resourcePool,
            'allocations': calculateAllocations(resourcePool)
          },
        if (reserved.isNotEmpty)
          'Reserved': {
            'employees': reserved,
            'allocations': calculateAllocations(reserved)
          },
        'totalAllocations': totalAllocations,
        'total': total,
      };
    }).toList();
  }

  void _calculatePracticeResourceSummary(List<Map<String, dynamic>> result) {
    double practiceTotal = 0.0;

    result.forEach((optionSummary) {
      final totalAllocations =
          optionSummary['totalAllocations'] as Map<String, double>;
      totalAllocations.forEach((designation, allocation) {
        practiceResourceSummary[designation] =
            (practiceResourceSummary[designation] ?? 0.0) + allocation;
      });

      practiceTotal += optionSummary['total'] ?? 0.0;
    });

    practiceResourceSummary['Total'] = practiceTotal;

  }


  List<String> summaryOptions = [];

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 1.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: DropdownButton<String>(
                      value: _selectedOption,
                      hint: const Text('Select Practice Group'),
                      onChanged: (value) => setState(() {
                        _selectedOption = value;
                        _assignSummaryOption();
                      }),
                      items:
                          _practices.map<DropdownMenuItem<String>>((practice) {
                        return DropdownMenuItem<String>(
                          value: practice['practiceId'].toString(),
                          child: Text(practice['practiceName']),
                        );
                      }).toList(),
                      isExpanded: true,
                      underline: const SizedBox(),
                    ),
            ),
            const SizedBox(height: 10),

            isLoading
                ? const Center(
                    child: CircularProgressIndicator()) 
                :
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_showSummaryDetailPage)
                      SummaryDetailPage(
                        selectedSummaryOption: _selectedSummaryOption,
                        selectedPractice: _selectedPractice,
                        popupMenuSelection:
                            _popupMenuSelection, 
                        result: result,
                        onBack: () => setState(() {
                          _showSummaryDetailPage = false;
                        }),
                      )
                    else
                      _buildSummarySection(
                        title: 'Practice Resource Summary',
                        practiceResourceSummary: practiceResourceSummary,
                        options: result,
                        onAction: (selectedOption, action) {
                        },
                      ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection({
    required String title,
    required List<Map<String, dynamic>> options,
    required Map<String, double> practiceResourceSummary,
    required void Function(String selectedOption, String action) onAction,
  }) {
    if (options.isEmpty) {
      return const Center(child: Text('No resources found '));
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 6,
              shadowColor: Colors.grey.shade300,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.withOpacity(0.05),
                      Colors.deepPurple.withOpacity(0.02),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: practiceResourceSummary.entries.map((entry) {
                        double progress = entry.value.toDouble() / 100;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${entry.key}: ${(progress * 100).toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                backgroundColor: Colors.grey[300],
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.deepPurpleAccent),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true, 
              physics:
                  const NeverScrollableScrollPhysics(), 
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                final optionTitle = option["option"];
                final totalAllocations =
                    option["totalAllocations"] as Map<String, num>;
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  color: const Color.fromARGB(255, 250, 249, 249),
                  elevation: 5,
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          optionTitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 16),
                          onSelected: (value) {
                            setState(() {
                              _selectedSummaryOption = optionTitle;
                              _popupMenuSelection = value;
                              _showSummaryDetailPage = true;
                            });
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'Summary',
                              child: Text('Summary'),
                            ),
                            const PopupMenuItem(
                              value: 'Resources',
                              child: Text('Resources'),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Column(
                          children: totalAllocations.entries.map((entry) {
                            double progress = (entry.value).toDouble() / 100;

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${entry.key}: ${(progress * 100).toStringAsFixed(2)}', 
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 8,
                                    backgroundColor: const Color.fromARGB(
                                        255, 230, 230, 230),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            Colors.deepPurpleAccent),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
