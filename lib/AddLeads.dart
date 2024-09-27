import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Database/DataAccessHandler.dart';
import 'Database/Palm3FoilDatabase.dart';
import 'Database/SyncService.dart';
import 'HomeScreen.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'common_styles.dart';

class AddLeads extends StatefulWidget {
  const AddLeads({super.key});

  @override
  _AddLeadScreenState createState() => _AddLeadScreenState();
}

class _AddLeadScreenState extends State<AddLeads>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();
  // TextEditingController _usernameController = TextEditingController();
  bool _isCompany = false;
  Palm3FoilDatabase? palm3FoilDatabase;
  Position? _currentPosition;
  final List<Uint8List> _images = [];
  final List<XFile> _imagepath = [];
  bool isImageList = false;
  final ImagePicker _picker = ImagePicker();
  final List<PlatformFile> _files = [];
  int? userID;
  String? _errorMessage;
  String? Username;
  void _pickFile() async {
    // Ensure the combined count of images and files is less than 3 before allowing the file picker
    if (_images.length + _files.length < 3) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'xls', 'xlsx'],
      );

      if (result != null) {
        // Limit the number of files added to not exceed the total of 3 files + images
        int availableSlots = 3 - (_images.length + _files.length);
        List<PlatformFile> selectedFiles =
        result.files.take(availableSlots).toList();

        setState(() {
          _files.addAll(selectedFiles);
        });
      }
    } else {
      // Show an error or handle the case when the limit is reached
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'You can upload a maximum of 3 files and images combined.')));
    }
  }

  void _deleteFile(int index) {
    setState(() {
      _files.removeAt(index);
    });
  }

  // Get current location (latitude and longitude)
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  @override
  void initState() {
    super.initState();

    getuserdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[50], // Background color
        elevation: 0, // Remove the shadow under the AppBar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Navigate to the previous screen
            Navigator.pop(context);
          },
        ),
        title: const Row(
          children: [
            Text(
              'Add Leads', // Add Leads beside the back arrow
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: "Name *",
                        hintText: "Enter Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Enter Name';
                        }
                        return null;
                      },
                    ),
                    Transform.translate(
                      offset: const Offset(-10, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _isCompany,
                            onChanged: (bool? value) {
                              setState(() {
                                _isCompany = value!;
                              });
                            },
                          ),
                          const Text("Is Company"),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: _isCompany,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _companyNameController,
                            decoration: InputDecoration(
                              labelText: "Company Name *",
                              hintText: "Enter Company Name",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            validator: (value) {
                              if (_isCompany &&
                                  (value == null || value.isEmpty)) {
                                return 'Please Enter Company Name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                    TextFormField(
                      controller: _phoneNumberController,
                      decoration: InputDecoration(
                        labelText: "Phone Number *",
                        hintText: "Enter Phone Number",
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Enter Phone Number';
                        } else if (value.length != 10) {
                          return 'Phone Number must be 10 digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: "Email *",
                        hintText: "Enter Email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Enter Email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _commentsController,
                      decoration: InputDecoration(
                        labelText: "Comments",
                        hintText: "Enter Comments",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    mobileImagePicker(context);
                                  },
                                  child: DottedBorder(
                                    color: CommonStyles.dotColor,
                                    strokeWidth: 2,
                                    dashPattern: const [6, 3],
                                    borderType: BorderType.RRect,
                                    radius: const Radius.circular(10),
                                    child: Container(
                                      height: 120,
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                            "assets/add_a_photo.svg",
                                            width: 50,
                                            height: 50,
                                            color: CommonStyles.dotColor,
                                          ),
                                          const SizedBox(height: 8),
                                          const Text('Upload Image',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: GestureDetector(
                                  onTap: _pickFile,
                                  child: DottedBorder(
                                    color: CommonStyles.dotColor,
                                    strokeWidth: 2,
                                    dashPattern: const [6, 3],
                                    borderType: BorderType.RRect,
                                    radius: const Radius.circular(10),
                                    child: Container(
                                      height: 120,
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                            "assets/fileuploadicon.svg",
                                            width: 50,
                                            height: 50,
                                            color: CommonStyles.dotColor,
                                          ),
                                          const SizedBox(height: 8),
                                          const Text('Upload Doc',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          if (_images.isNotEmpty) ...[
                            const Text('Uploaded Images:',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              children: _images.map((image) {
                                final int index = _images.indexOf(image);
                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: MemoryImage(image),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () => _deleteImage(index),
                                        child: Container(
                                          width: 24,
                                          height: 24,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.close,
                                              color: Colors.red, size: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ],
                          if (_files.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            const Text('Uploaded Files:',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _files.map((file) {
                                final int index = _files.indexOf(file);
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Stack(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          border:
                                          Border.all(color: Colors.blue),
                                          borderRadius:
                                          BorderRadius.circular(8),
                                          color: Colors.grey[100],
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.file_present,
                                                size: 30, color: Colors.blue),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                file.name,
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    overflow:
                                                    TextOverflow.ellipsis),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: GestureDetector(
                                          onTap: () => _deleteFile(index),
                                          child: Container(
                                            width: 24,
                                            height: 24,
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.close,
                                                color: Colors.red, size: 16),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ]
                        ],
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          backgroundColor: CommonStyles
                              .buttonbg, // You can customize the color here
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Add Lead",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          backgroundColor: Colors.transparent,
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      showLoadingDialog(context);
      _validateTotalItems();
      String? empCode = await fetchEmpCode(Username!, context);
      palm3FoilDatabase = await Palm3FoilDatabase.getInstance();
      final dataAccessHandler =
      Provider.of<DataAccessHandler>(context, listen: false);

      print('empCode===$empCode');

      if (empCode == null) {
        print('Error: EmpCode not found.');
        return;
      }

      String formattedDate = getCurrentDateInDDMMYY();

      String maxNumQuery = '''
  SELECT MAX(CAST(SUBSTR(code, INSTR(code, '-') + 1) AS INTEGER)) AS MaxNumber 
  FROM Leads  WHERE code LIKE 'L$empCode$formattedDate-%'
''';

      int? maxSerialNumber =
      await dataAccessHandler.getOnlyOneIntValueFromDb(maxNumQuery);

      int serialNumber = (maxSerialNumber != null) ? maxSerialNumber + 1 : 1;

      String formattedSerialNumber = serialNumber.toString().padLeft(3, '0');

      String leadCode = 'L$empCode$formattedDate-$formattedSerialNumber';
      print('LeadCode==$leadCode');
      await _getCurrentLocation();
      Navigator.of(context).pop();
      if (_currentPosition != null) {
        final leadData = {
          'IsCompany': _isCompany ? 1 : 0,
          'Code': leadCode,
          'Name': _nameController.text,
          'CompanyName': _isCompany ? _companyNameController.text : null,
          'PhoneNumber': _phoneNumberController.text,
          'Email': _emailController.text,
          'Comments': _commentsController.text,
          'Latitude': _currentPosition!.latitude,
          'Longitude': _currentPosition!.longitude,
          'CreatedByUserId': userID,
          'CreatedDate': DateTime.now().toIso8601String(),
          'UpdatedByUserId': userID,
          'UpdatedDate': DateTime.now().toIso8601String(),
          'ServerUpdatedStatus': false,
        };

        print('leadData======>$leadData');

        try {
          // Insert lead data into the database and get the inserted ID
          int leadId = await palm3FoilDatabase!.insertLead(leadData); // Ensure this returns the inserted ID
          print('leadId======>$leadId');

          for (var image in _imagepath) {
            // Prepare data for the FileRepositorys table
            String fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg'; // Modify as needed
            String fileLocation = image.path; // Define your file storage path
            String fileExtension = '.jpg'; // Adjust based on image type
            print('===fileLocation $fileLocation');
            final fileData = {
              'leadsCode': leadCode, // Use the retrieved lead ID here
              'FileName': fileLocation,
              //    'FileName': base64Encode(image), // Encode image as base64
              'FileLocation': fileLocation,
              'FileExtension': fileExtension,
              'IsActive': 1,
              'CreatedByUserId': userID, // Replace with actual user ID// Store as 1 for true
              'CreatedDate': DateTime.now().toIso8601String(),
              'UpdatedByUserId': userID, // Replace with actual user ID
              'UpdatedDate': DateTime.now().toIso8601String(),
              'ServerUpdatedStatus': false,
            };
            print('fileData======>$fileData');
            // Insert into FileRepositorys table
            await palm3FoilDatabase!.insertFileRepository(fileData);
          }

// Assuming `_files`, `leadCode`, `userID`, and `dataAccessHandler` are defined in your class
          for (var file in _files) {
            // Extract file extension
            String fileExtension = path.extension(file.name); // Get the file extension dynamically

            // Define your file storage path (assuming you have this logic)
            String fileLocation =
                ''; // Initialize or define your file storage path

            // Read file bytes
            String? filePath = file.path; // Get the path directly from the file object
            File fileObj = File(filePath!); // Rename the variable to avoid confusion

            // Read file bytes
            List<int> fileBytes = await fileObj.readAsBytes();

            // Encode bytes to base64
            String base64String = base64Encode(fileBytes);
            print('base64String====$base64String');

            // Encode file name in base64
            String base64FileName = base64Encode(utf8
                .encode(file.name)); // Uncommented and corrected variable name

            // Prepare the file data for insertion
            final fileData = {
              'leadsCode': leadCode, // Use the retrieved lead ID here
              'FileName': filePath,
              // 'FileName': base64String, // Use the original file name encoded in base64
              'FileLocation': filePath, // Define your file storage path
              'FileExtension':
              fileExtension, // Use the extracted file extension
              'IsActive': 1,
              'CreatedByUserId': userID, // Replace with actual user ID
              'CreatedDate': DateTime.now().toIso8601String(),
              'UpdatedByUserId': userID, // Replace with actual user ID
              'UpdatedDate': DateTime.now().toIso8601String(),
              'ServerUpdatedStatus': false,
            };

            print('fileData======>$fileData');

            // Insert into FileRepositorys table
            await palm3FoilDatabase!.insertFileRepository(fileData);
          }

          // Trigger Sync for Leads and FileRepository
          final syncService = SyncService(dataAccessHandler);
          syncService.performRefreshTransactionsSync(context);

          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => const HomeScreen()),
          // );

          // Clear all input fields and images
          _nameController.clear();
          _companyNameController.clear();
          _phoneNumberController.clear();
          _emailController.clear();
          _commentsController.clear();
          _images.clear(); // Clear the images list

          // Navigate to the home screen
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(content: Text('Lead Data Inserted Successfully!')),
          // );
        } catch (e) {
          // Handle database insertion failure
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to insert lead data.')),
          );
          print('Error inserting lead data: $e');
        }
      } else {
        // Location fetch failed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to get location.')),
        );
      }
    }
  }

  Future<void> mobileImagePicker(BuildContext context) async {
    // Ensure the combined count of images and files is less than 3 before showing the picker
    if (_images.length + _files.length < 3) {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Camera'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          );
        },
      );
    } else {
      // Show an error or handle the case when the limit is reached
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'You can upload a maximum of 3 files and images combined.')));
    }
  }

  // Method to pick image from specified source
  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        final Uint8List imageData = await pickedFile.readAsBytes();
        setState(() {
          _images.add(imageData);
          _imagepath.add(pickedFile);
          //  _imagepath.ad

        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  // Method to delete image from the list
  void _deleteImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _validateTotalItems() {
    // Combined count of images and files
    if (_images.length + _files.length > 3) {
      setState(() {
        _errorMessage =
        'You can upload a maximum of 3 images and files combined.';
      });
    } else {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  Future<void> getuserdata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userID = prefs.getInt('userID');
    Username = prefs.getString('username') ?? '';
    String firstName = prefs.getString('firstName') ?? '';
    String email = prefs.getString('email') ?? '';
    String mobileNumber = prefs.getString('mobileNumber') ?? '';
    String roleName = prefs.getString('roleName') ?? '';
  }

  String getCurrentDateInDDMMYY() {
    final DateTime now = DateTime.now();
    final String day = now.day.toString().padLeft(2, '0');
    final String month = now.month.toString().padLeft(2, '0');
    final String year = (now.year % 100).toString().padLeft(2, '0');
    return '$day$month$year';
  }

  Future<String?> fetchEmpCode(String username, BuildContext context) async {
    final dataAccessHandler =
    Provider.of<DataAccessHandler>(context, listen: false);

    // Use parameterized query to avoid SQL injection
    String empCodeQuery = 'SELECT EmpCode FROM UserInfos WHERE UserName = ?';

    // Fetch EmpCode using the query
    String? empCode = await dataAccessHandler
        .getOnlyOneStringValueFromDb(empCodeQuery, [username]);

    // Print the result
    if (empCode != null) {
      print('EmpCode: $empCode'); // Print the fetched EmpCode
    } else {
      print('EmpCode not found for UserName: $username');
    }

    return empCode; // Optionally return the EmpCode
  }
}
