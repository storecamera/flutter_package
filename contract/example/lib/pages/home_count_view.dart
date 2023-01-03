import 'package:example/service/login_service.dart';
import 'package:flutter/material.dart';
import 'package:contract/contract.dart';

class HomeCountContract extends Contract {

  int _counter = 0;

  int get counter => _counter;

  void incrementCounter() {
    _counter++;
    update();
  }
}

class HomeCountView extends ContractWidget<HomeCountContract> {
  HomeCountView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HomeLoginWidget(),
          const SizedBox(height: 32,),
          const Text(
            'You have pushed the button this many times:',
          ),
          const SizedBox(height: 16,),
          Text(
            '${contract.counter}',
            style: Theme.of(context).textTheme.headline4,
          ),
        ],
      ),
    );
  }
}

class HomeLoginWidget extends ContractWidget<LoginService> {

  HomeLoginWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if(contract.isLogin)
          ...[
            const Text('You are logged in'),
            const SizedBox(width: double.infinity, height: 8,),
            ElevatedButton(onPressed: () {
              contract.isLogin = false;
            }, child: const Text('Logout'))
          ]
        else
          ...[
            const Text('Please log in'),
            const SizedBox(width: double.infinity, height: 8,),
            ElevatedButton(onPressed: () {
              contract.isLogin = true;
            }, child: const Text('Login'))
          ]
      ],
    );
  }
}

// class HomeView extends ContractPageView<HomeBinder> {
//   HomeView({super.key});
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
//                   '${binder.counter}',
//                   style: Theme.of(context).textTheme.headline4,
//                 ),
//                 // ElevatedButton(
//                 //   onPressed: () async {
//                 //     final result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
//                 //       return ContractPageBuilder(
//                 //         binder: (_, binder, arguments) {
//                 //           binder.put(ResultCountContract());
//                 //           return true;
//                 //         },
//                 //         builder: (context) => ResultCountView(context),
//                 //       );
//                 //     },)
//                 //     );
//                 //     print('KKH Result : $result');
//                 //   },
//                 //   child: const Text('Result Count'),
//                 // ),
//                 ElevatedButton(
//                   onPressed: () async {
//                     // context.pushNamed('resultCount');
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
//                     // context.goNamed('family',
//                     //     params: <String, String>{'fid': e});
//                   },
//                 ))
//                     .toList(),
//               );
//             },
//           ))
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: binder.incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
