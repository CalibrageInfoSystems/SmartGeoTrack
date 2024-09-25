import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartgetrack/Model/LeadsModel.dart';
import 'package:smartgetrack/common_styles.dart';

import '../Database/DataAccessHandler.dart';

class CustomLeadTemplate extends StatelessWidget {
  final int index;
  final LeadsModel lead;

  const CustomLeadTemplate(
      {super.key, required this.index, required this.lead});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: index.isEven
            ? CommonStyles.listEvenColor
            : CommonStyles.listOddColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // Shadow color
            offset: const Offset(
                5, 5), // Move shadow to the right (x) and bottom (y)
            blurRadius: 10, // How blurred the shadow is
            spreadRadius: 1, // How much the shadow spreads
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (lead.name != null)
            Text(
              '${lead.name}',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          // Icon with a click action
          GestureDetector(
            onTap: () async {
    final dataAccessHandler = Provider.of<DataAccessHandler>(context, listen: false);


    String? base64Image = await dataAccessHandler.fetchBase64Image(lead.code!);

    if (base64Image != null) {
    Uint8List bytes = base64Decode(base64Image);

                //Uint8List bytes = base64Decode('');

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: Image.memory(bytes), // Show the image
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the popup
                          },
                          child: Text('Close'),
                        ),
                      ],
                    );
                  },
                );
             }
           },
            child: const Icon(Icons.arrow_circle_right_outlined),
          ),
        ],
      ),

          const SizedBox(height: 3),
          if (lead.companyName != null)
            listCustomText(
              '${lead.companyName}',
            ),
          if (lead.email != null)
            listCustomText(
              '${lead.email}',
            ),
          if (lead.phoneNumber != null)
            listCustomText('${lead.phoneNumber}', isSpace: false),
        ],
      ),
    );
  }

  Column listCustomText(String text, {bool isSpace = true}) {
    return Column(
      children: [
        Text(
          text,
          style: CommonStyles.txStyF16CbFF5
              .copyWith(color: CommonStyles.dataTextColor),
        ),
        if (isSpace) const SizedBox(height: 8),
      ],
    );
  }


}
