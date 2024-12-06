import 'package:flutter/material.dart';

class ResourceList extends StatefulWidget {
  final List<dynamic> employees;
  final Function(dynamic, String) onActionSelected;

  const ResourceList(
      {required this.employees, required this.onActionSelected, super.key});

  @override
  State<ResourceList> createState() => _ResourceListState();
}

class _ResourceListState extends State<ResourceList> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          widget.employees.isEmpty
              ? const Center(child: Text('No Resources Available'))
              : Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      itemCount: widget.employees.length,
                      itemBuilder: (context, index) {
                        final employee = widget.employees[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
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
                          child: ListTile(
                            title: Text(
                              employee['employeeName'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: const Text('Tap options to manage'),
                            trailing: PopupMenuButton<String>(
                              onSelected: (String value) {
                                widget.onActionSelected(employee,
                                    value);  
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'Active Projects',
                                  child: Text('Active Projects'),
                                ),
                                const PopupMenuItem(
                                  value: 'Previous Projects',
                                  child: Text('Previous Projects'),
                                ),
                              ],
                            ),
                            leading:
                                const Icon(Icons.person, color: Colors.blue),
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
}
