import 'package:contract/contract.dart';
import 'package:example/service/login_service.dart';
import 'package:flutter/material.dart';

class HomeCountContract extends Contract with AsyncWorker {

  int _counter = 0;

  int get counter => _counter;

  void incrementCounter() {
    _counter++;
    update();
  }

  @override
  void onResume() {
    super.onResume();

    final homeBinder = Contract.of(context);
    print('KKH $homeBinder');
  }

  void showError() {
    asyncWorker(
          () async {
        await Future.delayed(const Duration(seconds: 2));
        throw Exception('Error Message');
      },
      onError: (e) {
        // showDialog(context: context, builder: (context) {
        //   return AlertDialog(
        //     icon: const Icon(Icons.error_outline),
        //     content: Text(e.toString()),
        //     actions: [
        //       TextButton(onPressed: () {
        //         Navigator.pop(context);
        //       }, child: const Text('Ok'))
        //     ],
        //   );
        // });
        return e;
      }
    );
  }
}

class HomeCountView extends ContractWidget<HomeCountContract> {
  HomeCountView({super.key});

  @override
  Widget build(BuildContext context) {
    return AsyncWorkerWidget(
      worker: contract,
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HomeLoginWidget(),
            ElevatedButton(onPressed: () {
              contract.showError();
            }, child: const Text('show error')),
            const SizedBox(height: 32,),
            const Text(
              'You have pushed the button this many times:',
            ),
            const SizedBox(height: 16,),
            Text(
              '${contract.counter}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
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
