import 'package:flutter/material.dart';
import 'package:practice_management/utils/project_utils.dart';

class SummaryDetailPage extends StatefulWidget {
  final String? selectedSummaryOption;
  final String? selectedPractice;
  final String? popupMenuSelection;
  final List<Map<String, dynamic>> result; 

  final VoidCallback onBack;

  const SummaryDetailPage({
    super.key,
    this.selectedSummaryOption,
    this.selectedPractice,
    this.popupMenuSelection,
    required this.result,
    required this.onBack,
  });

  @override
  SummaryDetailPageState createState() => SummaryDetailPageState();
}

class SummaryDetailPageState extends State<SummaryDetailPage> {
  bool isLoaded = false;
  final List<String> tabLabels = ['Resource Pool', 'Billable', 'Reserved'];
  int selectedTab = 0;
  List<String> selectedBreadcrumbs = [];
  List<dynamic> employees = [];
  Map<String, double> summary = {};
  List<dynamic> resources = [];

  @override
  void initState() {
    super.initState();
    _onPracticeSelected();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() {
        isLoaded = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onPracticeSelected() async {
    setState(() {
      isLoaded = true; 
      summary = {};
    });

    if (!mounted) {
      return;
    } 

    if (widget.selectedSummaryOption == null) {
      setState(() {
        isLoaded = false; 
      });
      return;
    }

    final selectedSummaryData = widget.result.firstWhere(
      (item) => item['option'] == widget.selectedSummaryOption,
      orElse: () => <String, Object>{}, 
    );

    if (widget.popupMenuSelection == "Summary") {
      setState(() {
        summary = selectedSummaryData[tabLabels[selectedTab]]?['allocations'] ??
            {
              'Associate Software Engineer': 0.0,
              'Software Engineer': 0.0,
              'Senior Software Engineer': 0.0,
              'Lead Software Engineer': 0.0,
              'Principal Software Engineer': 0.0,
              'Technical Manager': 0.0,
              'Senior Technical Manager': 0.0,
            };
        resources = []; 
      });
    } else if (widget.popupMenuSelection == "Resources") {
      setState(() {
        resources =
            selectedSummaryData[tabLabels[selectedTab]]?['employees'] ?? [];
        summary = {};
      });
    }

    if (mounted) {
      setState(() {
        isLoaded = false; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  '${widget.selectedSummaryOption} > ${widget.popupMenuSelection}',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          DefaultTabController(
            length: tabLabels.length,
            initialIndex: selectedTab,
            child: Column(
              children: [
                _buildTabBar(),
                const SizedBox(height: 10),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.58,
                  child: isLoaded
                      ? const Center(
                          child: CircularProgressIndicator())  
                      : TabBarView(
                          children: tabLabels.map((label) {
                            if (widget.popupMenuSelection == "Resources") {
                              return _buildTabListView(label);
                            } else if (widget.popupMenuSelection == "Summary") {
                              return _buildSummaryView(label);
                            }
                            return const SizedBox(); 
                          }).toList(),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryView(String label) {
    if (summary.isEmpty && !isLoaded) {
      return Center(child: Text('No Summary found for $label'));
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
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: summary.entries.map((entry) {
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
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {

    return TabBar(
      onTap: (index) {
        setState(() {
          selectedTab = index;
          isLoaded = true;

          if (index >= 0 &&
              index < tabLabels.length &&
              widget.selectedPractice != null &&
              widget.selectedSummaryOption != null) {
            _onPracticeSelected();
          }
        });
      },
      labelColor: Colors.deepPurple,
      unselectedLabelColor: Colors.grey,
      indicatorColor: Colors.deepPurple,
      indicatorWeight: 3,
      tabs: tabLabels.map((label) => Tab(child: Text(label))).toList(),
    );
  }

  Widget _buildTabListView(String label) {
    if (resources.isEmpty) {
      return Center(child: Text('No employees found for $label'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: resources.length,
      itemBuilder: (context, index) {
        if (index < resources.length) {
          final employee = resources[index];
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
              child: Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: Text(employee['employeeName']),
                  subtitle: Text(
                      'Client: ${employee['clientname'] ?? 'N/A'}, Allocation: ${employee['projectAllocation'] ?? '0'}%'),
                  leading: const Icon(Icons.person, color: Colors.blue),
                  trailing: const Icon(Icons.expand_more), 
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0), 
                      alignment:
                          Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .start,
                        children: ProjectUtils.buildDetails(employee),
                      ),
                    ),
                  ],
                ),
              ));
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
