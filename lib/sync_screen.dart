import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:smartgetrack/Database/DataAccessHandler.dart';
import 'package:smartgetrack/Database/SyncService.dart';
import 'package:smartgetrack/HomeScreen.dart';
import 'package:smartgetrack/common_styles.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen>
    with SingleTickerProviderStateMixin {
  final dataAccessHandler = DataAccessHandler();
  int? pendingleadscount;
  int? pendingfilerepocount;
  int? pendingboundarycount;
  late Future<List<dynamic>> futureData;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    futureData = fetchPendinGrecordsCount();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void startAnimation() {
    _controller.repeat();
  }

  void stopAnimation() {
    _controller.stop();
  }

  Future<List<dynamic>> fetchPendinGrecordsCount() async {
    // Fetch pending counts
    pendingleadscount = await dataAccessHandler.getOnlyOneIntValueFromDb(
        'SELECT Count(*) AS pendingLeadsCount FROM Leads WHERE ServerUpdatedStatus = 0');
    pendingfilerepocount = await dataAccessHandler.getOnlyOneIntValueFromDb(
        'SELECT Count(*) AS pendingrepoCount FROM FileRepositorys WHERE ServerUpdatedStatus = 0');
    pendingboundarycount = await dataAccessHandler.getOnlyOneIntValueFromDb(
        'SELECT Count(*) AS pendingboundaryCount FROM GeoBoundaries WHERE ServerUpdatedStatus = 0');
    print(
        'fetchPendinGrecordsCount: $pendingleadscount | $pendingfilerepocount | $pendingboundarycount');
    return [pendingleadscount, pendingfilerepocount, pendingboundarycount];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar(),
      body: Center(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Please don\'t close the app while syncing is in progress.',
                      style: CommonStyles.txStyF14CbFF5.copyWith(
                        color: CommonStyles.dataTextColor,
                      ),
                    ),
                    const SizedBox(height: 30),
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _controller.value * 2 * 3.14,
                          child: child,
                        );
                      },
                      child: Image.asset(
                        'assets/synchronize.png',
                        height: 60,
                        width: 60,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FutureBuilder(
                        future: futureData,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox();
                            /*  return Column(
                              children: [
                                customRow(label: 'Leads', data: 0),
                                customRow(label: 'File Repository', data: 0),
                              ],
                            ); */
                          } else if (snapshot.hasError) {
                            return Text(
                                snapshot.error
                                    .toString()
                                    .replaceFirst('Exception: ', ''),
                                style: CommonStyles.txStyF16CpFF5);
                          } else {
                            final data = snapshot.data as List<dynamic>;
                            return Column(
                              children: [
                                customRow(label: 'Leads', data: data[0]),
                                customRow(
                                    label: 'File Repository', data: data[1]),
                              ],
                            );
                          }
                        }),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: syncData,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          backgroundColor: CommonStyles.buttonbg,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Sync Data",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget customRow({required String label, int? data}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('$label: ', style: CommonStyles.txStyF14CbFF5),
        Text('$data',
            style: CommonStyles.txStyF14CbFF5.copyWith(
              color: CommonStyles.dataTextColor,
            )),
      ],
    );
  }

  customBtn({required onPressed, required Text child}) {}

  AppBar appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: CommonStyles.listOddColor,
      leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          iconSize: 20,
          onPressed: () {
            Navigator.pop(context);
          }),
      title: const Text('Sync Offline Data', style: CommonStyles.txStyF20CbFF5),
    );
  }

  Future<void> syncData() async {
    bool isConnected = await CommonStyles.checkInternetConnectivity();
    if (isConnected) {
      startAnimation();
      final dataAccessHandler =
          Provider.of<DataAccessHandler>(context, listen: false);
      final syncService = SyncService(dataAccessHandler);
      syncService.performRefreshTransactionsSync(context).whenComplete(() {
        stopAnimation();
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const HomeScreen()));
      });
    } else {
      Fluttertoast.showToast(
          msg: "Please check your internet connection.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
}
