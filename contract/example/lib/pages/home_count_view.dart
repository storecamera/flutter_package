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

  @override
  void onResume() {
    super.onResume();

    final homeBinder = Contract.of(context);
    print('KKH $homeBinder');
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
