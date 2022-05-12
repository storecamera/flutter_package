import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'flutter_sheet_localization_generator.dart';

Builder flutterSheetLocalization(BuilderOptions options) => SharedPartBuilder(
    [SheetLocalizationGenerator()], 'flutter_sheet_localization');
