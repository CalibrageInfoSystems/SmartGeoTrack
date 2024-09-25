import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartgetrack/Common/custom_lead_template.dart';
import 'package:smartgetrack/Common/custom_textfield.dart';
import 'package:smartgetrack/common_styles.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  DateTime? selectedFromDate;
  DateTime? selectedToDate;
  String? displayFromDate;
  String? displayToDate;

  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CommonStyles.listOddColor,
        leading: const Icon(Icons.arrow_back),
        scrolledUnderElevation: 0,
        title: const Text(
          'View Lead',
          //  style: CommonStyles.txStyF14CbFF5,
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
      body: Scaffold(
        body: Column(
          children: [
            filterAndSearch(),
            /* Expanded(
              child: ListView.separated(
                itemCount: 22,
                itemBuilder: (context, index) {
                  return CustomLeadTemplate(
                    index: index,
                    lead: null,
                  );
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
              ),
            ), */
          ],
        ),
      ),
    );
  }

  Container filterAndSearch() {
    return Container(
      height: 60,
      color: CommonStyles.listOddColor,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: CommonStyles.whiteColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
              onPressed: () => openFilter(context),
              child: const Row(
                children: [
                  Icon(
                    Icons.filter_alt,
                    color: CommonStyles.dataTextColor,
                  ),
                  Text(
                    'Filter',
                    style: TextStyle(color: CommonStyles.dataTextColor),
                  ),
                ],
              )),
          const SizedBox(width: 10),
          Expanded(
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: CommonStyles.whiteColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10)),
                  onPressed: () {},
                  child: const Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        color: CommonStyles.dataTextColor,
                      ),
                      Text(
                        'Search',
                        style: TextStyle(color: CommonStyles.dataTextColor),
                      ),
                    ],
                  ))),
        ],
      ),
    );
  }

  List<String> dates = ['Today', 'This Week', 'Month'];
  List<String> types = ['Company', 'Individual'];
  int dateChipValue = 0;
  int typeChipValue = -1;

  void openFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Filter(
                dateChipValue: dateChipValue,
                typeChipValue: typeChipValue,
                dates: dates,
                types: types,
                fromDateController: fromDateController,
                toDateController: toDateController,
                onSelectedDateChip: (int selectedIndex) {
                  setModalState(() {
                    if (selectedIndex != -1) {
                      dateChipValue = selectedIndex;
                    }
                  });
                },
                onSelectedTypeChip: (int selectedIndex) {
                  setModalState(() {
                    // Allow type chip to be deselected (set to -1)
                    typeChipValue = selectedIndex;
                  });
                },
                onFromDate: () {
                  final DateTime currentDate = DateTime.now();
                  final DateTime firstDate = DateTime(currentDate.year - 2);
                  launchFromDatePicker(
                    context,
                    firstDate: firstDate,
                    lastDate: currentDate,
                  );
                },
                onToDate: () {
                  final DateTime currentDate = DateTime.now();
                  final DateTime firstDate = DateTime(currentDate.year - 100);
                  launchToDatePicker(context,
                      firstDate: selectedFromDate ?? firstDate,
                      lastDate: currentDate,
                      initialDate: selectedFromDate);
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<void> launchFromDatePicker(BuildContext context,
      {required DateTime firstDate,
      required DateTime lastDate,
      DateTime? initialDate}) async {
    // final DateTime lastDate = DateTime.now();
    // final DateTime firstDate = DateTime(lastDate.year - 100);
    final DateTime? pickedDay = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDatePickerMode: DatePickerMode.day,
    );
    if (pickedDay != null) {
      setState(() {
        selectedFromDate = pickedDay;
        fromDateController.text =
            DateFormat('dd/MM/yyyy').format(selectedFromDate!);
      });
    }
  }

  Future<void> launchToDatePicker(BuildContext context,
      {required DateTime firstDate,
      required DateTime lastDate,
      DateTime? initialDate}) async {
    // final DateTime lastDate = DateTime.now();
    // final DateTime firstDate = DateTime(lastDate.year - 100);
    final DateTime? pickedDay = await showDatePicker(
      context: context,
      // initialDate: DateTime.now(),
      initialDate: initialDate ?? DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDatePickerMode: DatePickerMode.day,
    );

    if (pickedDay != null) {
      setState(() {
        selectedToDate = pickedDay;
        toDateController.text =
            DateFormat('dd/MM/yyyy').format(selectedToDate!);
      });
    }
  }
}

class Filter extends StatefulWidget {
  final int dateChipValue;
  final int typeChipValue;
  final void Function(int)? onSelectedDateChip;
  final void Function(int)? onSelectedTypeChip;
  final List<String> dates;
  final List<String> types;
  final void Function()? onToDate;
  final void Function()? onFromDate;
  final TextEditingController? fromDateController;
  final TextEditingController? toDateController;

  const Filter({
    super.key,
    required this.dateChipValue,
    required this.typeChipValue,
    required this.dates,
    required this.types,
    this.onToDate,
    this.onFromDate,
    this.fromDateController,
    this.toDateController,
    this.onSelectedDateChip,
    this.onSelectedTypeChip,
  });

  @override
  State<Filter> createState() => _FilterState();
}

class _FilterState extends State<Filter> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 40),
              const Text('Filter', style: CommonStyles.txStyF20CbFF5),
              IconButton(
                  icon: const Icon(
                    Icons.close,
                  ),
                  iconSize: 20,
                  onPressed: () {
                    Navigator.pop(context);
                  })
            ],
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 12.0,
                      children: List<Widget>.generate(
                        widget.dates.length,
                        (int index) {
                          return ChoiceChip(
                            label: Text(
                              widget.dates[index],
                            ),
                            selectedColor: CommonStyles.btnBlueBgColor,
                            backgroundColor: CommonStyles.whiteColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                    color: CommonStyles.btnBlueBgColor)),
                            selected: widget.dateChipValue == index,
                            onSelected: (bool selected) {
                              if (widget.onSelectedDateChip != null) {
                                widget
                                    .onSelectedDateChip!(selected ? index : -1);
                              }
                            },
                          );
                        },
                      ).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 12.0,
                      children: List<Widget>.generate(
                        widget.types.length,
                        (int index) {
                          return ChoiceChip(
                            label: Text(
                              widget.types[index],
                            ),
                            selectedColor: CommonStyles.btnBlueBgColor,
                            backgroundColor: CommonStyles.whiteColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                    color: CommonStyles.btnBlueBgColor)),
                            // No chip selected initially if widget.typeChipValue == -1
                            selected: widget.typeChipValue == index,
                            onSelected: (bool selected) {
                              if (widget.onSelectedTypeChip != null) {
                                widget
                                    .onSelectedTypeChip!(selected ? index : -1);
                              }
                            },
                          );
                        },
                      ).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                CustomTextField(
                  label: 'From Date',
                  readOnly: true,
                  suffixIcon: const Icon(Icons.calendar_month_outlined),
                  onTap: widget.onFromDate,
                  controller: widget.fromDateController,
                ),
                const SizedBox(height: 15.0),
                CustomTextField(
                  label: 'To Date',
                  readOnly: true,
                  suffixIcon: const Icon(Icons.calendar_month_outlined),
                  onTap: widget.onToDate,
                  controller: widget.toDateController,
                ),
                const SizedBox(height: 20.0),
                Row(
                  children: [
                    Expanded(
                      child: customBtn(
                        onPressed: () {},
                        child: const Text(
                          'Submit',
                          style: CommonStyles.txStyF14CwFF5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: customBtn(
                          onPressed: () {},
                          child: const Text(
                            'Clear',
                            style: CommonStyles.txStyF14CwFF5,
                          ),
                          backgroundColor: CommonStyles.btnBlueBgColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ElevatedButton customBtn(
      {Color? backgroundColor = CommonStyles.btnRedBgColor,
      required Widget child,
      void Function()? onPressed}) {
    return ElevatedButton(
      onPressed: () {
        onPressed?.call();
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        backgroundColor: backgroundColor,
      ),
      child: child,
    );
  }
}
