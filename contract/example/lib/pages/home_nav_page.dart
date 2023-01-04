import 'package:flutter/material.dart';
import 'package:contract/contract.dart';

class HomeNavContract extends Contract {
  int _counter = 0;

  int get counter => _counter;

  void incrementCounter() {
    _counter++;
    update();
  }
}

class HomeNavWidget extends ContractWidget<HomeNavContract> {
  HomeNavWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Navigator(
          initialRoute: '/nav1',
          onGenerateRoute: (RouteSettings settings) {
            switch(settings.name) {
              case '/nav1':
                return MaterialPageRoute(
                    builder: (context) => const Nav1Page(),
                    settings: settings);
              case '/nav2':
                return MaterialPageRoute(
                    builder: (context) => ContractPageBuilder(
                      binder: (context, binder, arguments) {
                        binder.lazyPut(() => Nav2Contract());
                      },
                      builder: (context) => Nav2Widget(),
                    ),
                    settings: settings);
            }
            return null;
          },
        )
    );
  }
}

class HomeNavCounterWidget extends ContractWidget<HomeNavContract> {
  HomeNavCounterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'HomeNavContract Counter',
        ),
        const SizedBox(height: 16,),
        Text(
          '${contract.counter}',
          style: Theme.of(context).textTheme.headline4,
        ),
      ],
    );
  }
}

class Nav1Page extends ContractPage {
  const Nav1Page({Key? key}) : super(key: key);

  @override
  BinderContract createBinder() => Nav1Binder();

  @override
  Widget build(BuildContext context) => Nav1Widget();
}

class Nav1Binder extends BinderContract {

  int _counter = 0;

  int get counter => _counter;

  void incrementCounter() {
    _counter++;
    update();
  }
}

class Nav1Widget extends ContractWidget<Nav1Binder> {
  Nav1Widget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        HomeNavCounterWidget(),
        const SizedBox(height: 32,),
        const Text(
          'Nav1Counter Counter',
        ),
        const SizedBox(height: 16,),
        Text(
          '${contract.counter}',
          style: Theme.of(context).textTheme.headline4,
        ),
        const SizedBox(height: 16,),
        ElevatedButton(onPressed: () {
          contract.incrementCounter();
        }, child: const Text('Nav1Counter Plus')),
        const SizedBox(height: 32,),
        ElevatedButton(onPressed: () {
          Navigator.of(context).pushNamed('/nav2');
        }, child: const Text('Push Nav2')),
      ],
    );
  }
}

class Nav2Contract extends Contract {
  int _counter = 0;

  int get counter => _counter;

  void incrementCounter() {
    _counter++;
    update();
  }
}

class Nav2Widget extends ContractWidget<Nav2Contract> {
  Nav2Widget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        HomeNavCounterWidget(),
        const SizedBox(height: 32,),
        const Text(
          'Nav2Counter Counter',
        ),
        const SizedBox(height: 16,),
        Text(
          '${contract.counter}',
          style: Theme.of(context).textTheme.headline4,
        ),
        const SizedBox(height: 16,),
        ElevatedButton(onPressed: () {
          contract.incrementCounter();
        }, child: const Text('Nav2Counter Plus')),
        const SizedBox(height: 32,),
        ElevatedButton(onPressed: () {
          Navigator.pop(context);
        }, child: const Text('Back')),
      ],
    );
  }
}
