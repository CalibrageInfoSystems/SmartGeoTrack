import 'dart:convert';
import 'dart:io';

import 'package:open_file/open_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:smartgetrack/Database/DataAccessHandler.dart';
import 'package:smartgetrack/Model/lead_info_model.dart';
import 'package:smartgetrack/common_styles.dart';

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

  @override
  void initState() {
    super.initState();
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
      return leads;
    } catch (e) {
      throw Exception('catch: ${e.toString()}');
    }
  }

  void openTheFile(String filePath) {
    OpenFile.open(filePath);
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
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    // return Text('Error: ${snapshot.error}');
                    return Text(
                        snapshot.error
                            .toString()
                            .replaceFirst('Exception: ', ''),
                        style: CommonStyles.txStyF16CpFF5);
                  } else if (!snapshot.hasData) {
                    return const Text('No data');
                  }
                  final leads = snapshot.data as List<LeadInfoModel>;
                  if (leads.isEmpty) {
                    return const SizedBox();
                  }
                  return Column(
                    children: [
                      const SizedBox(height: 12),
                      leadInfo(leads[0]),
                    ],
                  );
                },
              ),
              FutureBuilder(
                future: futureLeadImages,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (!snapshot.hasData && snapshot.data!.isEmpty) {
                    return const SizedBox();
                  }
                  final leads = snapshot.data!;
                  return Column(
                    children: [
                      const SizedBox(height: 12),
                      uploadmages(leads),
                    ],
                  );
                },
              ),
              FutureBuilder(
                future: futureLeadImages,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (!snapshot.hasData && snapshot.data!.isEmpty) {
                    return const SizedBox();
                  }
                  final leads = snapshot.data!;
                  return Column(
                    children: [
                      const SizedBox(height: 12),
                      uploadDocs(leads),
                    ],
                  );
                },
              ),
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
                    updatedDetailItem(label: 'Updated At', data: '12-12-2022'),
                    updatedDetailItem(label: 'Updated By', data: '12-12-2022'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
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
              'Uploaded Images:',
              style: CommonStyles.txStyF16CbFF5,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 20,
              children: [
                ...leads.map(
                  (lead) =>
                      customDoc(lead['FileLocation'], leads.indexOf(lead)),
                ),
              ],
            )
          ]),
    );
  }

  Column customDoc(String filePath, int index) {
    return Column(
      children: [
        GestureDetector(
            onTap: () => openTheFile(filePath),
            child: SvgPicture.asset('assets/add_a_photo.svg',
                width: 70, height: 70)),
        const SizedBox(height: 5),
        Text(
          'Doc-$index',
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
                (lead) => Image.file(
                  File(lead['FileLocation']),
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                ),
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
              /* IconButton(
                      icon: const Icon(Icons.location_on,
                          color: CommonStyles.formFieldErrorBorderColor),
                      onPressed: () {},
                    ), */
              const Icon(Icons.location_on,
                  color: CommonStyles.formFieldErrorBorderColor),
            ],
          ),
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

  Container leadInfoShimmer() {
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
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lead Name',
                style: CommonStyles.txStyF16CpFF5,
              ),
              /* IconButton(
                      icon: const Icon(Icons.location_on,
                          color: CommonStyles.formFieldErrorBorderColor),
                      onPressed: () {},
                    ), */
              Icon(Icons.location_on,
                  color: CommonStyles.formFieldErrorBorderColor),
            ],
          ),
          const SizedBox(height: 5),
          listCustomText('ABCD Company'),
          listCustomText('test@test.in'),
          listCustomText('+91 9249234422'),
          const Text('Comment:',
              style: TextStyle(
                  fontSize: 16, color: CommonStyles.primaryTextColor)),
          const SizedBox(height: 3),
          const Text(
              'It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout.',
              style: CommonStyles.txStyF14CbFF5),
        ],
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
}
