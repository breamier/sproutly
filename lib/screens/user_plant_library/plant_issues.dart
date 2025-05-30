import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sproutly/models/plant_issue.dart';
import 'package:sproutly/services/database_service.dart';

class PlantIssuesScreen extends StatefulWidget {
  final String plantId;

  const PlantIssuesScreen({super.key, required this.plantId});

  @override
  State<PlantIssuesScreen> createState() => _PlantIssuesScreenState();
}

class _PlantIssuesScreenState extends State<PlantIssuesScreen> {
  final Color oliveTitleColor = const Color(0xFF747822);
  final Color lightBackgroundColor = const Color(0xFFF7F7F2);

  bool _showResolvedIssues = false;
  final TextEditingController _newIssueController = TextEditingController();

  @override
  void dispose() {
    _newIssueController.dispose();
    super.dispose();
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  String _formatTime(DateTime dateTime) {
    int hour = dateTime.hour;
    String period = hour >= 12 ? 'PM' : 'AM';

    if (hour > 12) {
      hour -= 12;
    } else if (hour == 0) {
      hour = 12;
    }

    String minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  void _addNewIssue() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
            title: Text(
              'Add New Plant Issue',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: oliveTitleColor,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _newIssueController,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Type plant issue here',
                      hintStyle: TextStyle(
                        fontFamily: 'Poppins',
                        color: oliveTitleColor.withOpacity(0.5),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: oliveTitleColor),
                      ),
                    ),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: oliveTitleColor,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(color: oliveTitleColor)),
              ),
              TextButton(
                onPressed: () async {
                  if (_newIssueController.text.isNotEmpty) {
                    // Add issue to firestore
                    final issue = PlantIssue(
                      id: '',
                      plantId: widget.plantId,
                      issueDescription: _newIssueController.text,
                      resolved: false,
                      createdAt: Timestamp.now(),
                    );

                    await DatabaseService().addPlantIssue(
                      widget.plantId,
                      issue,
                    );
                    setState(() {
                      _newIssueController.clear();
                    });
                    Navigator.pop(context);
                  }
                },
                child: Text('Add', style: TextStyle(color: oliveTitleColor)),
              ),
            ],
          ),
    );
  }

  Future<void> _markAsResolved(String issueId, PlantIssue issue) async {
    final updated = PlantIssue(
      id: issue.id,
      plantId: issue.plantId,
      issueDescription: issue.issueDescription,
      resolved: true,
      createdAt: issue.createdAt,
    );
    await DatabaseService().updatePlantIssue(widget.plantId, issueId, updated);
  }

  Future<void> _onDeletePressed(String issueId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Plant Issue'),
            content: const Text('Are you sure you want to delete this issue?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
    if (confirm == true) {
      await DatabaseService().deletePlantIssue(widget.plantId, issueId);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showResolvedIssues) {
      return Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8E8D5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: oliveTitleColor,
                              width: 1.5,
                            ),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Color(0xFF747822),
                            ),
                            onPressed: () {
                              setState(() {
                                _showResolvedIssues = false;
                              });
                            },
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Text(
                          'Plant Issues',
                          style: TextStyle(
                            fontFamily: 'Curvilingus',
                            fontSize: 34,
                            color: oliveTitleColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Text(
                  'Resolved Issues',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: oliveTitleColor,
                  ),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: StreamBuilder(
                    stream: DatabaseService().getPlantIssues(widget.plantId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'No resolved issues found',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                  color: oliveTitleColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final List<PlantIssue> resolvedIssues =
                          snapshot.data!.docs
                              .where((doc) => (doc.data().resolved))
                              .map((doc) => doc.data())
                              .toList();

                      if (resolvedIssues.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'No resolved issues found',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                  color: oliveTitleColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: resolvedIssues.length,
                        itemBuilder: (context, index) {
                          final issue = resolvedIssues[index];
                          final createdDate = issue.createdAt.toDate();
                          final formattedDate =
                              "${_getMonthName(createdDate.month)} ${createdDate.day}, ${createdDate.year}, ${_formatTime(createdDate)}";

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              color: lightBackgroundColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        issue.issueDescription,
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 16,
                                          color: oliveTitleColor,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        formattedDate,
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Color(0xFF747822),
                                  ),
                                  onPressed: () => _onDeletePressed(issue.id),
                                  tooltip: 'Delete issue',
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: oliveTitleColor, width: 2.0),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Plant Issues',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: oliveTitleColor,
                  ),
                ),
                Row(
                  children: [
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showResolvedIssues = true;
                        });
                      },
                      child: Image.asset(
                        'assets/resolved_icon.png',
                        height: 30,
                        width: 30,
                        color: oliveTitleColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: StreamBuilder(
                  stream: DatabaseService().getPlantIssues(widget.plantId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'No plant issues found',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18,
                                color: oliveTitleColor,
                              ),
                            ),
                            const Spacer(),
                            Divider(
                              color: oliveTitleColor.withOpacity(0.3),
                              thickness: 1,
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: _addNewIssue,
                              child: Row(
                                children: [
                                  Text(
                                    "+ Add a new plant issue",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      color: oliveTitleColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final List<PlantIssue> issues =
                        snapshot.data!.docs
                            .where((doc) => !(doc.data().resolved))
                            .map((doc) => doc.data())
                            .toList();

                    if (issues.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'No unresolved issues found',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18,
                                color: oliveTitleColor,
                              ),
                            ),
                            const Spacer(),
                            Divider(
                              color: oliveTitleColor.withOpacity(0.3),
                              thickness: 1,
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: _addNewIssue,
                              child: Row(
                                children: [
                                  Text(
                                    "+ Add a new plant issue",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      color: oliveTitleColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: issues.length + 1,
                      itemBuilder: (context, index) {
                        if (index < issues.length) {
                          final issue = issues[index];
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      issue.issueDescription,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16,
                                        color: oliveTitleColor,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap:
                                        () => _markAsResolved(issue.id, issue),
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: oliveTitleColor,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Divider(
                                color: oliveTitleColor.withOpacity(0.3),
                                thickness: 1,
                              ),
                              const SizedBox(height: 10),
                            ],
                          );
                        } else {
                          return GestureDetector(
                            onTap: _addNewIssue,
                            child: Row(
                              children: [
                                Text(
                                  "+ Add a new plant issue",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    color: oliveTitleColor,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
