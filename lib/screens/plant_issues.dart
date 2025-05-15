import 'package:flutter/material.dart';

class PlantIssuesScreen extends StatefulWidget {
  final Map<String, dynamic> plant;

  const PlantIssuesScreen({
    super.key,
    required this.plant,
  });

  @override
  State<PlantIssuesScreen> createState() => _PlantIssuesScreenState();
}

class _PlantIssuesScreenState extends State<PlantIssuesScreen> {
  final Color oliveTitleColor = const Color(0xFF747822);
  final Color lightBackgroundColor = const Color(0xFFF7F7F2);
  final List<String> _currentIssues = ['Wiltering', 'Overwatering', 'Yellowing of leaves'];
  final List<String> _resolvedIssues = [
    'Black spots',
    'Bacterial wilt',
    'Insufficient or excessive sunlight',
    'Poor soil composition'
  ];
  bool _showResolvedIssues = false;
  final TextEditingController _newIssueController = TextEditingController();

  @override
  void dispose() {
    _newIssueController.dispose();
    super.dispose();
  }

  void _addNewIssue() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Add New Plant Issue',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: oliveTitleColor,
          ),
        ),
        content: TextField(
          controller: _newIssueController,
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: oliveTitleColor),
            ),
          ),
          TextButton(
            onPressed: () {
              if (_newIssueController.text.isNotEmpty) {
                setState(() {
                  _currentIssues.add(_newIssueController.text);
                  _newIssueController.clear();
                });
                Navigator.pop(context);
              }
            },
            child: Text(
              'Add',
              style: TextStyle(color: oliveTitleColor),
            ),
          ),
        ],
      ),
    );
  }

  void _markAsResolved(int index) {
    setState(() {
      final resolvedIssue = _currentIssues.removeAt(index);
      _resolvedIssues.add(resolvedIssue);
    });
  }

  @override
  Widget build(BuildContext context) {
    // If showing resolved issues, use full screen
    if (_showResolvedIssues) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8E8D5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: oliveTitleColor, width: 1.5),
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
                      'Resolved Issues',
                      style: TextStyle(
                        fontFamily: 'Curvilingus',
                        fontSize: 34,
                        color: oliveTitleColor,
                        fontWeight: FontWeight.bold,
                      ),
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
                  child: ListView.builder(
                    itemCount: _resolvedIssues.length,
                    itemBuilder: (context, index) {
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
                        child: Text(
                          _resolvedIssues[index],
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            color: oliveTitleColor,
                          ),
                        ),
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
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(20),
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
            const SizedBox(height: 20),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _currentIssues.length + 1,
                itemBuilder: (context, index) {
                  if (index < _currentIssues.length) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _currentIssues[index],
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  color: oliveTitleColor,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _markAsResolved(index),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}