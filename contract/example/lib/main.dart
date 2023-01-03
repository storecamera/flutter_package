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
              builder: (context) => ContractPageBuilder(
                    binder: (BuildContext context, PageBinder binder,
                        dynamic arguments) {
                      if (arguments is Map) {
                        binder.put(PersonContract(
                          arguments['family'],
                          arguments['person'],
                        ));
                      } else {
                        throw ContractExceptions.invalidArguments.exception;
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

// /// Home Page
// class HomePage extends ContractPage<HomeContractPageState> {
//   const HomePage({Key? key}) : super(key: key);
//
//   @override
//   HomeContractPageState createState() => HomeContractPageState();
//
//   @override
//   Widget build(BuildContext context, HomeContractPageState pageState) => HomeView(
//     context,
//   );
// }
//
// class HomeContractPageState extends ContractPageState {
//   int _counter = 0;
//
//   int get counter => _counter;
//
//   @override
//   void initBinding() {
//
//   }
//
//   void incrementCounter() {
//     _counter++;
//     setState(() {});
//   }
//
//   @override
//   void init() {
//     super.init();
//     print('HomeContract init');
//     Service.of<IsCurrentService>().addListener(() {
//       print('KKH Home isCurrent : ${ModalRoute.of(context)?.isCurrent} isFirst : ${ModalRoute.of(context)?.isFirst} isActive : ${ModalRoute.of(context)?.isActive}');
//     });
//   }
//
//   @override
//   void dispose() {
//     print('HomeContract dispose');
//     super.dispose();
//   }
//
//   @override
//   void resumeLifeCycle() {
//     print('HomeContract resumeLifeCycle');
//   }
//
//   @override
//   void pauseLifeCycle() {
//     print('HomeContract pauseLifeCycle');
//   }
// }
//
// class HomeView extends ContractView<HomeContract> {
//   HomeView(BuildContext context, {Key? key}) : super(context, key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Home'),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 16.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 const Text(
//                   'You have pushed the button this many times:',
//                 ),
//                 Text(
//                   '${contract.counter}',
//                   style: Theme.of(context).textTheme.headline4,
//                 ),
//                 ElevatedButton(
//                   onPressed: () async {
//                     final result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
//                       return ContractPageBuilder(
//                         binder: (_, binder, arguments) {
//                           binder.put(ResultCountContract());
//                           return true;
//                         },
//                         builder: (context) => ResultCountView(context),
//                       );
//                     },)
//                     );
//                     print('KKH Result : $result');
//                   },
//                   child: const Text('Result Count'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () async {
//                     context.pushNamed('resultCount');
//                   },
//                   child: const Text('resultCount'),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(child: ServiceBuilder<FamilyService>(
//             builder: (context, service) {
//               return ListView(
//                 children: service
//                     .getFamily()
//                     .map((e) => ListTile(
//                   title: Text(e),
//                   onTap: () {
//                     context.goNamed('family',
//                         params: <String, String>{'fid': e});
//                   },
//                 ))
//                     .toList(),
//               );
//             },
//           ))
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: contract.incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
//
// /// Family page
// class FamilyContract extends Contract {
//   final String family;
//   late final List<String> persons = FamilyService.instance().getPerson(family);
//
//   FamilyContract(this.family);
//
//   @override
//   void init() {
//     super.init();
//     print('FamilyContract init');
//   }
//
//   @override
//   void dispose() {
//     print('FamilyContract dispose');
//     super.dispose();
//   }
//
//   @override
//   void resumeLifeCycle() {
//     print('FamilyContract resumeLifeCycle');
//   }
//
//   @override
//   void pauseLifeCycle() {
//     print('FamilyContract pauseLifeCycle');
//   }
// }
//
// class FamilyView extends ContractView<FamilyContract> {
//   FamilyView(BuildContext context, {Key? key}) : super(context, key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(contract.family),
//       ),
//       body: ListView(
//         children: contract.persons
//             .map((e) => ListTile(
//           title: Text(e),
//           onTap: () {
//             context.go(context.namedLocation(
//               'person',
//               params: <String, String>{
//                 'fid': contract.family,
//                 'pid': e
//               },
//               queryParams: <String, String>{'qid': 'quid'},
//             ));
//           },
//         ))
//             .toList(),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
//

//
// /// The login screen.
// class LoginScreen extends StatelessWidget {
//   /// Creates a [LoginScreen].
//   const LoginScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Login')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             ElevatedButton(
//               onPressed: () {
//                 Service.of<LoginService>().isLogin = true;
//               },
//               child: const Text('Login'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// /// Result Count
// class ResultCountContract extends Contract {
//   int _counter = 0;
//
//   int get counter => _counter;
//
//   void incrementCounter() {
//     _counter++;
//     notifyListeners();
//   }
//
//   @override
//   void init() {
//     super.init();
//     print('ResultCountContract init');
//   }
//
//   @override
//   void dispose() {
//     print('ResultCountContract dispose');
//     super.dispose();
//   }
//
//   @override
//   void resumeLifeCycle() {
//     print('ResultCountContract resumeLifeCycle');
//   }
//
//   @override
//   void pauseLifeCycle() {
//     print('ResultCountContract pauseLifeCycle');
//   }
// }
//
// class ResultCountView extends ContractView<ResultCountContract> {
//   ResultCountView(BuildContext context, {Key? key}) : super(context, key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('ResultCount'),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 16.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 const Text(
//                   'You have pushed the button this many times:',
//                 ),
//                 Text(
//                   '${contract.counter}',
//                   style: Theme.of(context).textTheme.headline4,
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(context, MaterialPageRoute(builder: (context) {
//                       return ContractPageBuilder(
//                         binder: (_, binder, arguments) {
//                           binder.put(ResultCountNextContract());
//                           return true;
//                         },
//                         builder: (context) => ResultCountNextView(context),
//                       );
//                     },)
//                     );
//                   },
//                   child: const Text('Next'),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: Center(
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.of(context).pop(contract.counter);
//                 },
//                 child: const Text('Result'),
//               ),
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: contract.incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
//
// class ResultCountNextContract extends Contract {
//
//   @override
//   void init() {
//     super.init();
//     print('ResultCountNextContract init');
//   }
//
//   @override
//   void dispose() {
//     print('ResultCountNextContract dispose');
//     super.dispose();
//   }
//
//   @override
//   void resumeLifeCycle() {
//     print('ResultCountNextContract resumeLifeCycle');
//   }
//
//   @override
//   void pauseLifeCycle() {
//     print('ResultCountNextContract pauseLifeCycle');
//   }
// }
//
// class ResultCountNextView extends ContractView<ResultCountNextContract> {
//   ResultCountNextView(BuildContext context, {Key? key}) : super(context, key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('ResultCountNextView'),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 16.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 const Text(
//                   'ResultCountNextView',
//                 ),
//                 ElevatedButton(onPressed: () {
//                   Service.of<IsCurrentService>().update();
//                 }, child: const Text('isCurrent'))
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
