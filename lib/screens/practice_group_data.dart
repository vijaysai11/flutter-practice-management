import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:practice_management/constants/config.dart';
import 'package:practice_management/pages/active_projects.dart';
import 'package:practice_management/pages/previous_projects.dart';
import 'package:practice_management/pages/resource-list.dart';
import 'package:collection/collection.dart';
import 'package:practice_management/services/api_service.dart';

class PracticeGroup extends StatefulWidget {
  const PracticeGroup({super.key});

  @override
  PracticeGroupState createState() => PracticeGroupState();
}

class PracticeGroupState extends State<PracticeGroup> {
  String? _selectedPractice;
  List<String> selectedBreadcrumbs = ['Resources'];
  List<dynamic> _practices = [];
  List<dynamic> _employees = [];
  bool _isLoading = false;
  final apiService =
      ApiService(baseUrl: Config.baseUrl);
  dynamic data;

  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _filteredEmployees = [];

  Widget?
      currentWidget; 

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterEmployees);


  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      // data = await apiService.get('', token: Config.token);
      final String response = await rootBundle.loadString('assets/data.json');
     data = json.decode(response);
      setState(() {
        _practices = [
          {'practiceId': '0', 'practiceName': 'All Practices'},
          ...data['employeePractices']
        ];

        _onPracticeSelected('0');

        currentWidget = ResourceList(
          employees: _employees,
          onActionSelected: _handleActions,
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _filterEmployees() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredEmployees = _employees.where((employee) {
        return (employee['employeeName']?.toLowerCase().contains(query) ??
                false) ||
            (employee['projectName']?.toLowerCase().contains(query) ?? false) ||
            (employee['clientname']?.toLowerCase().contains(query) ?? false) ||
            (employee['designation']?.toLowerCase().contains(query) ?? false) ||
            (employee['currentReportingHead']?.toLowerCase().contains(query) ??
                false) ||
            (employee['projectResourceStatusValue']
                    ?.toLowerCase()
                    .contains(query) ??
                false) ||
            (employee['notes']?.toLowerCase().contains(query) ?? false);
      }).toList();

      currentWidget = ResourceList(
        employees: _filteredEmployees,
        onActionSelected: _handleActions,
      );
    });
  }

  void _onPracticeSelected(String? practiceId) async {
    setState(() {
      _isLoading = true;
      _selectedPractice = practiceId;
    });
    selectedBreadcrumbs.length == 1 ? null : _goBack();
    final startTime = DateTime.now();

    if (practiceId == null) return;

    final allEmployees = (practiceId == '0')
        ? data['data'].expand((practice) {
            final resources = practice['projectResourcesData'];
            return resources is Iterable ? resources : [];
          }).toList()
        : (data['data'].firstWhere(
              (element) => element['practiceId'].toString() == practiceId,
              orElse: () => null,
            )?['projectResourcesData'] ??
            []);

    final endTime = DateTime.now();

    final elapsedTime = endTime.difference(startTime);
    await Future.delayed(
      const Duration(seconds: 2) - elapsedTime,
      () => {}, 
    );

    setState(() {
      _isLoading = false;

      final groupedEmployees = <String, Map<String, List<dynamic>>>{};

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

      _employees = groupedEmployees.entries.map((entry) {
        return {
          'employeeName': entry.key,
          'activeProjects': entry.value['activeProjects'],
          'previousProjects': entry.value['previousProjects'],
        };
      }).toList();

      currentWidget = ResourceList(
        employees: _employees,
        onActionSelected: _handleActions,
      );
    });
  }

  void _goBack() {
    if (selectedBreadcrumbs.length >= 2) {
      setState(() {
        selectedBreadcrumbs.removeRange(
            selectedBreadcrumbs.length - 1, selectedBreadcrumbs.length);

        currentWidget = ResourceList(
          employees: _employees,
          onActionSelected: _handleActions,
        );
      });
    } else if (selectedBreadcrumbs.length == 1) {
      setState(() {
        selectedBreadcrumbs.clear();
        currentWidget = ResourceList(
          employees: _employees,
          onActionSelected: _handleActions,
        );
      });
    }
  }

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
                value: _selectedPractice,
                hint: const Text('Select Practice Group'),
                onChanged: _onPracticeSelected,
                items: _practices.map<DropdownMenuItem<String>>((practice) {
                  return DropdownMenuItem<String>(
                    value: practice['practiceId'].toString(),
                    child: Text(practice['practiceName']),
                  );
                }).toList(),
                isExpanded: true,
                underline: const SizedBox(),
              ),
            ),
            const SizedBox(height: 20),

            
            Container(
              padding: const EdgeInsets.all(8.0),
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
              child: Row(
                children: [
                  selectedBreadcrumbs.length >= 2
                      ? IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: _goBack,
                        )
                      : const SizedBox.shrink(),
                  Expanded(
                    child: Wrap(
                      children: selectedBreadcrumbs.mapIndexed((index, crumb) {
                        return Row(
                          mainAxisSize:
                              MainAxisSize.min, 
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                crumb,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (index !=
                                selectedBreadcrumbs.length -
                                    1) 
                              const Text(' > '),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            selectedBreadcrumbs.length == 1
                ? SizedBox(
                    width: 250,
                    height: 40,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) =>
                          _filterEmployees(), 
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search Resources...',
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 12.0),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  )
                : const SizedBox(),

            _isLoading
                ? const Center(
                    child: CircularProgressIndicator()) 
                : Expanded(child: currentWidget ?? const SizedBox()),
          ],
        ),
      ),
    );
  }

  // Show previous data (filtered by employee)
  // Handle action selection from the EmployeeList
  void _handleActions(dynamic employee, String value) {
    final matchingRecords = _employees
        .where((e) => e['employeeName'] == employee['employeeName'])
        .toList();

    if (matchingRecords.isNotEmpty) {
      final selectedEmployee = matchingRecords.first;
      final activeProjects = selectedEmployee['activeProjects'] ?? [];
      final previousProjects = selectedEmployee['previousProjects'] ?? [];

      if (value == 'Active Projects') {
        setState(() {
          currentWidget = ActiveProjects(
            employeeName: selectedEmployee['employeeName'],
            activeProjects: activeProjects,
          );
          selectedBreadcrumbs.add(
              '${employee['employeeName']} > $value');
        });
      } else if (value == 'Previous Projects') {
        setState(() {
          selectedBreadcrumbs.add(
              '${employee['employeeName']} > $value');

          currentWidget = PreviousProjects(
            employeeName: selectedEmployee['employeeName'],
            previousProjects: previousProjects,
          );
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No matching records found for the employee.'),
          backgroundColor: Colors.red,
          duration:  Duration(seconds: 3),
        ),
      );
    }
  }
}
