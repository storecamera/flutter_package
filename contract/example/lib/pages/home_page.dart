import 'package:example/pages/home_family_page.dart';
import 'package:flutter/material.dart';
import 'package:contract/contract.dart';

import 'home_count_view.dart';
import 'home_nav_page.dart';

class HomePage extends ContractPage {
  const HomePage({Key? key}) : super(key: key);

  @override
  PageBinder createBinder() => HomeBinder();

  @override
  Widget build(BuildContext context) => HomeWidget();
}

class HomeBinder extends PageBinder with SingleTickerProviderStateMixin {
  late final TabController tabController =
      TabController(initialIndex: tabIndex.value, length: 3, vsync: this);

  final tabIndex = Contract.value(value: 0);

  @override
  void onInit() {
    super.onInit();
    lazyPut(() => HomeCountContract());
    lazyPut(() => HomeNavContract());

    tabController.addListener(() {
      final index = tabController.index;
      if (tabIndex.value != index) {
        tabIndex.value = index;
      }
    });
  }

  @override
  void onDispose() {
    super.onDispose();
    tabController.dispose();
  }
}

class HomeWidget extends ContractWidget<HomeBinder> {
  HomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: TabBarView(
        controller: contract.tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          HomeCountView(),
          HomeNavWidget(),
          HomeFamilyWidget(),
        ],
      ),
      bottomNavigationBar: contract.tabIndex.builder(
        valueBuilder: (valueBuilder, value) {
          return BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.numbers), label: 'Counter'),
              BottomNavigationBarItem(icon: Icon(Icons.navigation), label: 'Nav'),
              BottomNavigationBarItem(icon: Icon(Icons.family_restroom), label: 'Family'),
            ],
            currentIndex: value,
            onTap: (index) {
              contract.tabController.animateTo(index, duration: const Duration(milliseconds: 500));
            },
          );
        }
      ),
      floatingActionButton: contract.tabIndex.builder(valueBuilder: (context, value) {
        if(value == 0) {
          return FloatingActionButton(
            onPressed: () {
              Contract.of<HomeCountContract>(context).incrementCounter();
            },
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          );
        } else if(value == 1) {
          return FloatingActionButton(
            onPressed: () {
              Contract.of<HomeNavContract>(context).incrementCounter();
            },
            tooltip: 'Increment',
            child: const Icon(Icons.plus_one),
          );
        }
        return const SizedBox();
      }),
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
