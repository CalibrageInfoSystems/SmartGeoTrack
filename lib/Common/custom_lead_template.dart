import 'package:flutter/material.dart';
import 'package:smartgetrack/common_styles.dart';

class CustomLeadTemplate extends StatelessWidget {
  final int index;
  final Map<String, dynamic> lead; // Lead as a map

  const CustomLeadTemplate({super.key, required this.index, required this.lead});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: index.isEven
            ? CommonStyles.listEvenColor
            : CommonStyles.listOddColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                lead['Name'] ?? 'No Name', // Access 'name' from the map
                style: CommonStyles.txStyF16CbFF5,
              ),
              const Icon(Icons.arrow_circle_right_outlined),
            ],
          ),
          const SizedBox(height: 3),
          listCustomText(lead['CompanyName'] ?? 'No Company'),  // Access 'company'
          listCustomText(lead['Email'] ?? 'No Email'),      // Access 'email'
          listCustomText(lead['PhoneNumber'] ?? 'No Phone'),      // Access 'phone'
        ],
      ),
    );
  }

  Column listCustomText(String text) {
    return Column(
      children: [
        Text(
          text,
          style: CommonStyles.txStyF16CbFF5
              .copyWith(color: CommonStyles.dataTextColor),
        ),
        const SizedBox(height: 5),
      ],
    );
  }
}
