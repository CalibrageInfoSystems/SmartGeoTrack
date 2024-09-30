import 'dart:convert';
import 'dart:io';

import 'package:open_file/open_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartgetrack/Database/DataAccessHandler.dart';
import 'package:smartgetrack/Model/lead_info_model.dart';
import 'package:smartgetrack/common_styles.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewLeadsInfo extends StatefulWidget {
  final String code;
  const ViewLeadsInfo({super.key, required this.code});

  @override
  State<ViewLeadsInfo> createState() => _ViewLeadsInfoState();
}

class _ViewLeadsInfoState extends State<ViewLeadsInfo> {
  late Future<List<LeadInfoModel>> futureLeadInfo;
  late Future<List<Map<String, dynamic>>> futureLeadImages;
  late Future<List<Map<String, dynamic>>> futureLeadDocs;
  String? username;
  @override
  void initState() {
    super.initState();
    getusername();
    futureLeadInfo = getLeadInfoByCode(widget.code);

    futureLeadImages = getLeadImagesByCode(widget.code);
    futureLeadDocs = getLeadDocsByCode(widget.code);
  }

  Future<List<LeadInfoModel>> getLeadInfoByCode(String code) async {
    try {
      final dataAccessHandler =
          Provider.of<DataAccessHandler>(context, listen: false);
      List<dynamic> result = await dataAccessHandler.getLeadInfoByCode(code);
      List<LeadInfoModel> leads =
          result.map((item) => LeadInfoModel.fromJson(item)).toList();
      print('xxx Info: ${jsonEncode(leads)}');
      return leads;
    } catch (e) {
      throw Exception('catch: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> getLeadImagesByCode(String code) async {
    try {
      final dataAccessHandler =
          Provider.of<DataAccessHandler>(context, listen: false);
      List<dynamic> result =
          await dataAccessHandler.getLeadImagesByCode(code, '.jpg');
      List<Map<String, dynamic>> leads =
          result.map((item) => Map<String, dynamic>.from(item)).toList();
      print('xxx Images: ${jsonEncode(leads)}');
      return leads;
    } catch (e) {
      throw Exception('catch: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> getLeadDocsByCode(String code) async {
    try {
      final dataAccessHandler =
          Provider.of<DataAccessHandler>(context, listen: false);
      List<dynamic> result = await dataAccessHandler.getLeadDocsByCode(
        code,
        ['.xlsx', '.pdf'],
      );
      List<Map<String, dynamic>> leads =
          result.map((item) => Map<String, dynamic>.from(item)).toList();
      print('xxx Docs: ${jsonEncode(leads)}');
      return leads;
    } catch (e) {
      throw Exception('catch: ${e.toString()}');
    }
  }

  Future<void> openLocalFileByPath(String? filePath) async {
    print('openLocalFileByPath: $filePath');
    if (filePath != null && filePath.isNotEmpty) {
      final file = File(filePath);
      if (await file.exists()) {
        await OpenFile.open(filePath);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File not found'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: SingleChildScrollView(
          child: Column(
            children: [
              FutureBuilder(
                future: futureLeadInfo,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Column(
                      children: [
                        const SizedBox(height: 12),
                        CommonStyles.customShimmer(child: leadInfoShimmer()),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Text(
                        snapshot.error
                            .toString()
                            .replaceFirst('Exception: ', ''),
                        style: CommonStyles.txStyF16CpFF5);
                  } else {
                    final leads = snapshot.data as List<LeadInfoModel>;

                    if (leads.isEmpty) {
                      return const SizedBox();
                    } else {
                      return Column(
                        children: [
                          const SizedBox(height: 12),
                          leadInfo(leads[0]),
                        ],
                      );
                    }
                  }
                },
              ),
              FutureBuilder(
                future: futureLeadImages,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Column(
                      children: [
                        const SizedBox(height: 12),
                        CommonStyles.customShimmer(
                            child: leadInfoShimmer(height: 100)),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Text(
                        snapshot.error
                            .toString()
                            .replaceFirst('Exception: ', ''),
                        style: CommonStyles.txStyF16CpFF5);
                  } else {
                    final leads = snapshot.data!;

                    if (leads.isEmpty) {
                      return const SizedBox();
                    } else {
                      return Column(
                        children: [
                          const SizedBox(height: 12),
                          uploadmages(leads),
                        ],
                      );
                    }
                  }
                },
              ),
              FutureBuilder(
                future: futureLeadDocs,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Column(
                      children: [
                        const SizedBox(height: 12),
                        CommonStyles.customShimmer(
                            child: leadInfoShimmer(height: 100)),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Text(
                        snapshot.error
                            .toString()
                            .replaceFirst('Exception: ', ''),
                        style: CommonStyles.txStyF16CpFF5);
                  } else {
                    final leads = snapshot.data!;

                    if (leads.isEmpty) {
                      return const SizedBox();
                    } else {
                      return Column(
                        children: [
                          const SizedBox(height: 12),
                          uploadDocs(leads),
                        ],
                      );
                    }
                  }
                },
              ),
              FutureBuilder(
                future: futureLeadInfo,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Column(
                      children: [
                        const SizedBox(height: 12),
                        CommonStyles.customShimmer(child: leadInfoShimmer()),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Text(
                        snapshot.error
                            .toString()
                            .replaceFirst('Exception: ', ''),
                        style: CommonStyles.txStyF16CpFF5);
                  } else {
                    final leads = snapshot.data as List<LeadInfoModel>;

                    if (leads.isEmpty) {
                      return const SizedBox();
                    } else {
                      return Column(
                        children: [
                          const SizedBox(height: 12),
                          updatedDetails(leads[0]),
                        ],
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Column updatedDetails(LeadInfoModel lead) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: CommonStyles.listEvenColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Updated Details:',
                style: CommonStyles.txStyF16CpFF5,
              ),
              const SizedBox(height: 10),
              updatedDetailItem(
                  label: 'Updated At',
                  data: CommonStyles.formatDateString(lead.createdDate)),
              updatedDetailItem(
                label: 'Updated By',
                data: username,
              )
            ],
          ),
        ),
      ],
    );
  }

  Row updatedDetailItem({required String label, String? data}) {
    return Row(
      children: [
        Text('$label: ', style: CommonStyles.txStyF14CbFF5),
        Text('$data',
            style: CommonStyles.txStyF14CbFF5
                .copyWith(color: CommonStyles.dataTextColor)),
      ],
    );
  }

  Container uploadDocs(List<Map<String, dynamic>> leads) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CommonStyles.listOddColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Uploaded Documents:',
              style: CommonStyles.txStyF16CbFF5,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 20,
              children: [
                ...leads.map(
                  (lead) => customDoc(lead, leads.indexOf(lead)),
                ),
              ],
            )
          ]),
    );
  }

  Column customDoc(Map<String, dynamic> lead, int index) {
    return Column(
      children: [
        GestureDetector(
            onTap: () => openLocalFileByPath(lead['FileLocation']),
            child: SvgPicture.asset('assets/fileDownloadIcon.svg',
                color: CommonStyles.btnBlueBgColor, width: 70, height: 70)),
        const SizedBox(height: 5),
        Text(
          'Doc${lead['FileExtension']}',
          style: CommonStyles.txStyF14CbFF5,
        )
      ],
    );
  }

  Container uploadmages(List<Map<String, dynamic>> lead) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CommonStyles.listEvenColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Uploaded Images:',
            style: CommonStyles.txStyF16CbFF5,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 20,
            children: [
              ...lead.map(
                (lead) {
                  return GestureDetector(
                    onTap: () => showZoomedAttachment(lead['FileLocation']),
                    child: Image.file(
                      File(lead['FileLocation']),
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          SvgPicture.asset(
                        'assets/fileuploadicon.svg',
                        width: 70,
                        height: 70,
                        color: CommonStyles.btnBlueBgColor,
                      ),
                    ),
                  );
                },
              ),
              /* Image.file(
                    File(lead['FileLocation']),
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ), */

              /* SvgPicture.asset('assets/fileuploadicon.svg',
                  width: 70, height: 70), */
            ],
          )
        ],
      ),
    );
  }

  void showZoomedAttachment(String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            width: double.infinity,
            height: 500,
            child: Stack(
              children: [
                Center(
                  child: PhotoViewGallery.builder(
                    itemCount: 1,
                    builder: (context, index) {
                      return PhotoViewGalleryPageOptions(
                        imageProvider:
                            FileImage(File(imagePath)), // Use FileImage
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.covered,
                      );
                    },
                    scrollDirection: Axis.vertical,
                    scrollPhysics: const PageScrollPhysics(),
                    allowImplicitScrolling: true,
                    backgroundDecoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Container leadInfo(LeadInfoModel lead) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CommonStyles.listOddColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${lead.name}',
                style: CommonStyles.txStyF16CpFF5,
              ),
              GestureDetector(
                onTap: () => _openMap(lead.latitude!, lead.longitude!),
                child: const Icon(Icons.location_on,
                    color: CommonStyles.formFieldErrorBorderColor),
              ),
              /*  IconButton(
                icon: const Icon(Icons.location_on,
                    color: CommonStyles.formFieldErrorBorderColor),
                onPressed: () {
                  _openMap(lead.latitude!,
                      lead.longitude!);
                },
              ), */
            ],
          ),
          const SizedBox(height: 5),
          if (lead.companyName != null)
            listCustomText(
              '${lead.companyName}',
            ),
          const SizedBox(height: 5),
          if (lead.email != null)
            listCustomText(
              '${lead.email}',
            ),
          const SizedBox(height: 5),
          if (lead.phoneNumber != null)
            listCustomText(
              '${lead.phoneNumber}',
            ),
          const SizedBox(height: 5),
          if (lead.comments != null && lead.comments!.isNotEmpty) ...[
            const Text('Comment:',
                style: TextStyle(
                    fontSize: 16, color: CommonStyles.primaryTextColor)),
            const SizedBox(height: 3),
            Text('${lead.comments}', style: CommonStyles.txStyF14CbFF5),
          ]
        ],
      ),
    );
  }

  Container leadInfoShimmer({double? height = 130}) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CommonStyles.listOddColor,
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      backgroundColor: CommonStyles.appBarBgColor,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back),
      ),
      scrolledUnderElevation: 0,
      title: const Text(
        'View Lead',
      ),
    );
  }

  Text listCustomText(String text, {bool isSpace = true}) {
    return Text(
      text,
      style: CommonStyles.txStyF16CbFF5,
    );
  }

  void _openMap(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }

  Future<void> getusername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    username = prefs.getString('username') ?? '';
  }
}
