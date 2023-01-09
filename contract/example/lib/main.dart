import 'package:contract/contract.dart';
import 'package:example/pages/family_page.dart';
import 'package:example/service/login_service.dart';
import 'package:flutter/material.dart';

import 'pages/home_page.dart';
import 'pages/person_page.dart';
import 'service/family_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Service.put(LoginService());
  Service.lazyPut(() => FamilyService());

  runApp(MaterialApp(
    title: 'Contract example',
    debugShowCheckedModeBanner: false,
    navigatorObservers: [ContractObserver.instance],
    initialRoute: '/',
    onGenerateRoute: (RouteSettings settings) {
      switch (settings.name) {
        case '/':
          return MaterialPageRoute(
              builder: (context) => const HomePage(), settings: settings);
        case '/family':
          return MaterialPageRoute(
              builder: (context) => FamilyPage(
                    arguments: settings.arguments,
                  ),
              settings: settings);
        case '/person':
          return MaterialPageRoute(
              builder: (context) => ContractBinderPageBuilder(
                    binder: (BuildContext context, BinderContract binder,
                        dynamic arguments) {
                      if (arguments is Map) {
                        binder.put(PersonContract(
                          arguments['family'],
                          arguments['person'],
                        ));
                      } else {
                        throw const ContractExceptionInvalidArguments();
                      }
                    },
                    builder: (context) => PersonWidget(),
                    arguments: settings.arguments,
                  ),
              settings: settings);
      }
      return null;
    },
  ));
}
