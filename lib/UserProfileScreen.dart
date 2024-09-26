import 'package:flutter/material.dart';

class UserProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Section
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.red,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'M Praven Kumar',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'ABCD Software Solutions',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text('praveen@abcd.com'),
                          Text('+91-7894561230'),
                          SizedBox(height: 8),
                          Text(
                            'Comment:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Uploaded Images Section
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Uploaded Images',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Image.asset('assets/ic_add.png', width: 80, height: 100),
                        SizedBox(width: 8),
                        Image.asset('assets/ic_add.png', width: 80, height: 100),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Uploaded Documents Section
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Uploaded Docs',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Icon(Icons.picture_as_pdf, size: 48, color: Colors.red),
                            SizedBox(height: 4),
                            Text('Doc 1'),
                          ],
                        ),
                        Column(
                          children: [
                            Icon(Icons.picture_as_pdf, size: 48, color: Colors.red),
                            SizedBox(height: 4),
                            Text('Doc 2'),
                          ],
                        ),
                        Column(
                          children: [
                            Icon(Icons.picture_as_pdf, size: 48, color: Colors.red),
                            SizedBox(height: 4),
                            Text('Doc 3'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Updated Details Section
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Updated Details',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('Updated At: 18-12-2024-08:45:56'),
                    Text('Updated By: V Naresh Rao'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
