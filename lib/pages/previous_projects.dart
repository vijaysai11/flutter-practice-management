import 'package:flutter/material.dart';
import 'package:practice_management/utils/project_utils.dart';

class PreviousProjects extends StatefulWidget {
  final String employeeName;
  final List<dynamic> previousProjects;

  const PreviousProjects({
    required this.employeeName,
    required this.previousProjects,
     super.key,
  });

  @override
  State<PreviousProjects> createState() => _PreviousProjectsState();
}

class _PreviousProjectsState extends State<PreviousProjects> {
  late List<bool> _expanded; 

  @override
  void initState() {
    super.initState();
    _expanded = List<bool>.filled(widget.previousProjects.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          widget.previousProjects.isEmpty
              ? const Center(child: Text('No Previous Projects Available'))
              : Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      itemCount: widget.previousProjects.length,
                      itemBuilder: (context, index) {
                        final project = widget.previousProjects[index];
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
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14),
                                ),
                                subtitle: Text(
                                  'Duration: ${project['startDate'] ?? 'N/A'} - ${project['endDate'] ?? 'N/A'}',
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    _expanded[index]
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _expanded[index] = !_expanded[index];
                                    });
                                  },
                                ),
                                // leading: const Icon(Icons.arrow_right, color: Colors.black,size: 30,),
                              ),
                              if (_expanded[index])
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical:
                                          8.0), 
                                  alignment: Alignment
                                      .centerLeft,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start, 
                                    children:
                                        ProjectUtils.buildDetails(project),
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
}
