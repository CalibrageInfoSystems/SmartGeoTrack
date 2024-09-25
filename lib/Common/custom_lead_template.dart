import 'package:flutter/material.dart';
import 'package:smartgetrack/common_styles.dart';

class CustomLeadTemplate extends StatelessWidget {
  final int index;
  const CustomLeadTemplate({super.key, required this.index});

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
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Jessy',
                style: CommonStyles.txStyF16CbFF5,
              ),
              Icon(Icons.arrow_circle_right_outlined),
            ],
          ),
          const SizedBox(height: 3),
          listCustomText('ABCD Software Solutions'),
          listCustomText('test@test.com'),
          listCustomText('+91 1234567890'),
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
