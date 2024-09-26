import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartgetrack/Model/LeadsModel.dart';
import 'package:smartgetrack/common_styles.dart';
import 'package:smartgetrack/view_leads_info.dart';

import '../Database/DataAccessHandler.dart';

class CustomLeadTemplate extends StatelessWidget {
  final int index;
  final LeadsModel lead;
  final void Function()? onTap;

  const CustomLeadTemplate(
      {super.key, required this.index, required this.lead, this.onTap});

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
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              GestureDetector(
                onTap: onTap,
                /* () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ViewLeadsInfo()));
                  
                }, */
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
        if (isSpace) const SizedBox(height: 5),
      ],
    );
  }
}
