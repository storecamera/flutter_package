import 'package:flutter/widgets.dart';

const supportedLocale = [
  Locale('en', 'US'),
  Locale('en', 'CA'),
  Locale('ko', 'KR'),
  Locale('id', 'ID'),
];

const Map<String, String> flags = {
  'US': 'flags/us.png',
  'CA': 'flags/ca.png',
  'KR': 'flags/kr.png',
  'ID': 'flags/id.png',
};

const Map<String, String> languageString = {
  'en': 'English',
  'ko': '한국어',
  'id': 'bahasa Indonesia',
};

const Map<String, String> countryString = {
  'US': 'United States',
  'CA': 'Canada',
  'KR': '대한민국',
  'ID': 'Indonesia',
};

extension LocaleExtension on Locale {
  String getLanguageString() =>
      languageString[languageCode.toLowerCase()] ?? languageCode;

  String getCountryString() =>
      countryString[countryCode?.toUpperCase()] ?? countryCode ?? '';

  String? getCountryFlagAsset() => flags[countryCode?.toUpperCase()];
}

class CountryFlag extends StatelessWidget {
  final String? countryCode;
  final double? width;
  final double? height;
  final BoxFit? boxFit;

  const CountryFlag(
      {super.key,
      required this.countryCode,
      this.width,
      this.height,
      this.boxFit});

  @override
  Widget build(BuildContext context) {
    final flag = flags[countryCode?.toUpperCase()];
    if (flag != null) {
      if (width != null && height != null) {
        return Image.asset(flag,
            package: 'store_camera_template',
            width: width,
            height: height,
            fit: boxFit ?? BoxFit.cover);
      } else if (width != null) {
        return Image.asset(flag,
            package: 'store_camera_template',
            width: width,
            fit: boxFit ?? BoxFit.fitWidth);
      } else if (height != null) {
        return Image.asset(flag,
            package: 'store_camera_template',
            width: height,
            fit: boxFit ?? BoxFit.fitHeight);
      } else {
        return Image.asset(
          flag,
          width: 24,
          package: 'store_camera_template',
          fit: boxFit ?? BoxFit.fitWidth,
        );
      }
    }

    return SizedBox(
      width: width,
      height: height,
    );
  }
}
