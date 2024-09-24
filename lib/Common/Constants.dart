
class Constants {
  static const String profileUrl =
      "https://avatars2.githubusercontent.com/u/7047347?s=460&v=4";
  static const String isLogin = "login_verification";
  static const String userId = "userID";
  static const String welcome = "welcome";

  static const String defaultLanguage = "english";
  static const String englishLanguage = "english";
  static const String teluguLanguage = "telugu";
  static const String kannadaLanguage = "kannada";

/*   static Future<void> launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  } */

  // static Future<void> launchMap(
  //     {required double? latitude, required double? longitude}) async {
  //   final Uri mapUrl = Uri.parse(
  //       'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
  //
  //   if (latitude != null && longitude != null) {
  //     if (!await launchUrl(
  //       mapUrl,
  //       mode: LaunchMode.externalApplication,
  //     )) {
  //       throw Exception('Could not launch $mapUrl');
  //     }
  //   } else {
  //     print('No latitude or longitude found');
  //   }
  // }
}