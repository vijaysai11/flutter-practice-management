import 'package:flutter/material.dart';
import 'package:practice_management/constants/config.dart';
import 'package:practice_management/services/api_service.dart';
import 'package:practice_management/utils/project_utils.dart';

class ActiveProjects extends StatefulWidget {
  final String employeeName;
  final List<dynamic> activeProjects;

  const ActiveProjects({
    required this.employeeName,
    required this.activeProjects,
    super.key});

  @override
  State<ActiveProjects> createState() => _ActiveProjectsState();
}

class _ActiveProjectsState extends State<ActiveProjects> {
  late List<bool> _expanded; 
  final apiService =
      ApiService(baseUrl: Config.baseUrl);
  dynamic data;
  List<Map<String, dynamic>> allStatuses = [];

  @override
  void initState() {
    super.initState();
    _expanded = List<bool>.filled(widget.activeProjects.length, false);
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          widget.activeProjects.isEmpty
              ? const Center(child: Text('No Active Projects Available'))
              : Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      itemCount: widget.activeProjects.length,
                      itemBuilder: (context, index) {
                        final project = widget.activeProjects[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                title: Text(
                                  project['projectName'] ?? 'N/A',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                    'Client: ${project['clientname'] ?? 'N/A'}'),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'Edit') {
                                      _showEditDialog(project, index);
                                    } else if (value == 'Details') {
                                      setState(() {
                                        _expanded[index] = !_expanded[index];
                                      });
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'Edit',
                                      child: Text('Edit'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'Details',
                                      child: Text('Details'),
                                    ),
                                  ],
                                ),
                                // leading: const Icon(Icons.arrow_right, color: Colors.black,size: 30,),
                              ),
                              if (_expanded[index])
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8.0),
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ...ProjectUtils.buildDetails(project),
                                      Align(
                                        alignment: Alignment.center,
                                        child: IconButton(
                                          icon: const Icon(
                                              Icons.keyboard_arrow_down),
                                          onPressed: () {
                                            setState(() {
                                              _expanded[index] =
                                                  false; 
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> project, int index) async {
    final TextEditingController commentsController =
        TextEditingController(text: project['notes'] ?? '');

    List<String> dropdownOptions = project['projectName'] == 'RESOURCE POOL'
        ? allStatuses
            .where((status) =>
                status['projectResourceStatusValue'] != 'Required In Project')
            .map((status) => status['projectResourceStatusValue'] as String)
            .toList()
        : allStatuses
            .map((status) => status['projectResourceStatusValue'] as String)
            .toList();

    String selectedStatus =
        project['projectResourceStatusValue'] ?? dropdownOptions.first;

    if (!dropdownOptions.contains(selectedStatus)) {
      selectedStatus = project['projectResourceStatusValue'];

      if (!dropdownOptions.contains(selectedStatus)) {
        dropdownOptions.add(selectedStatus);
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Project Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: commentsController,
                decoration: const InputDecoration(labelText: 'Comments'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value:
                    selectedStatus, 
                decoration: const InputDecoration(labelText: 'Status'),
                items: dropdownOptions.map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedStatus = newValue;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final selectedStatusObj = allStatuses.firstWhere(
                  (status) =>
                      status['projectResourceStatusValue'] == selectedStatus,
                  orElse: () => {
                    'projectResourceStatusId': -1, 
                  },
                );

                final requestBody = [
                  {
                    "notes": commentsController.text,
                    "projectResourceId": project['projectResourceId'],
                    "projectResourceStatusId":
                        selectedStatusObj['projectResourceStatusId'],
                  }
                ];

                final response =
                    await apiService.post('', requestBody, token: Config.token);
                if (response == 'SUCCESS') {
                  setState(() {
                    project['notes'] = commentsController.text;
                    project['projectResourceStatusValue'] = selectedStatus;
                  });
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Failed to save changes. Please try again.')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
