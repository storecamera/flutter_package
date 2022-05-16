import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:contract/contract.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Service.put(IsCurrentService());
  Service.put(LoginService());
  Service.lazyPut(() => FamilyService());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  late final GoRouter _router = GoRouter(
    debugLogDiagnostics: true,
    routes: <GoRoute>[
      GoRoute(
        name: 'home',
        path: '/',
        builder: (BuildContext context, GoRouterState state) =>
        const HomePage(),
        routes: <GoRoute>[
          GoRoute(
            name: 'family',
            path: 'family/:fid',
            builder: (BuildContext context, GoRouterState state) =>
                ContractPageBuilder<GoRouterState>(
                  binder: (_, binder, arguments) {
                    binder.put(FamilyContract(arguments?.params['fid'] ?? ''));
                    return true;
                  },
                  builder: (context) => FamilyView(context),
                  arguments: state,
                  // family: Families.family(state.params['fid']!),
                ),
            routes: <GoRoute>[
              GoRoute(
                name: 'person',
                path: 'person/:pid',
                builder: (BuildContext context, GoRouterState state) {
                  return ContractPageBuilder<GoRouterState>(
                    binder: (_, binder, arguments) {
                      binder.put(PersonContract(arguments?.params['fid'] ?? '',
                          arguments?.params['pid'] ?? ''));
                      return true;
                    },
                    builder: (context) => PersonView(context),
                    arguments: state,
                    // family: Families.family(state.params['fid']!),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        name: 'login',
        path: '/login',
        builder: (BuildContext context, GoRouterState state) =>
        const LoginScreen(),
      ),
      GoRoute(
        name: 'resultCount',
        path: '/resultCount',
        builder: (BuildContext context, GoRouterState state) {
          return ContractPageBuilder<GoRouterState>(
            binder: (_, binder, arguments) {
              binder.put(ResultCountContract());
              return true;
            },
            builder: (context) => ResultCountView(context),
            arguments: state,
            // family: Families.family(state.params['fid']!),
          );
        },
      ),
    ],

    // redirect to the login page if the user is not logged in
    redirect: (GoRouterState state) {
      // if the user is not logged in, they need to login
      final loginService = Service.of<LoginService>();
      final bool loggedIn = loginService.isLogin;
      final String loginloc = state.namedLocation('login');
      final bool loggingIn = state.subloc == loginloc;

      // bundle the location the user is coming from into a query parameter
      final String homeloc = state.namedLocation('home');
      final String fromloc = state.subloc == homeloc ? '' : state.subloc;
      if (!loggedIn) {
        return loggingIn
            ? null
            : state.namedLocation(
          'login',
          queryParams: <String, String>{
            if (fromloc.isNotEmpty) 'from': fromloc
          },
        );
      }

      // if the user is logged in, send them where they were going before (or
      // home if they weren't going anywhere)
      if (loggingIn) {
        return state.queryParams['from'] ?? homeloc;
      }

      // no need to redirect at all
      return null;
    },

    // changes on the listenable will cause the router to refresh it's route
    refreshListenable: Service.of<LoginService>(),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: _router.routeInformationParser,
      routerDelegate: _router.routerDelegate,
      title: 'Contract example',
      debugShowCheckedModeBanner: false,
    );
  }
}

class IsCurrentService extends Service {
  void update() => notifyListeners();
}

class LoginService extends Service {
  bool _isLogin = false;

  bool get isLogin => _isLogin;

  set isLogin(bool value) {
    if (_isLogin != value) {
      _isLogin = value;
      notifyListeners();
    }
  }
}

class FamilyService extends Service {
  static FamilyService instance() => Service.of<FamilyService>();

  final Map<String, List<String>> _family = {
    'Sells': ['Chris', 'John', 'Tom'],
    'Addams': ['Gomez', 'Morticia', 'Pugsley', 'Wednesday'],
    'Hunting': [
      'Mom',
      'Dad',
      'Will',
      'Marky',
      'Ricky',
      'Danny',
      'Terry',
      'Mikey',
      'Davey'
    ],
  };

  List<String> getFamily() => _family.keys.toList();

  List<String> getPerson(String family) => _family[family]?.toList() ?? [];

  @override
  void init() {
    print('KKH FamilyService init');
    super.init();
  }
}

/// Home Page
class HomePage extends ContractPage {
  const HomePage({Key? key}) : super(key: key);

  @override
  bool binding(BuildContext context, ContractBinder binder, arguments) {
    binder.put(HomeContract());
    return true;
  }

  @override
  Widget build(BuildContext context) => HomeView(
    context,
  );
}

class HomeContract extends Contract {
  int _counter = 0;

  int get counter => _counter;

  void incrementCounter() {
    _counter++;
    notifyListeners();
  }

  @override
  void init() {
    super.init();
    print('HomeContract init');
    Service.of<IsCurrentService>().addListener(() {
      print('KKH Home isCurrent : ${ModalRoute.of(context)?.isCurrent} isFirst : ${ModalRoute.of(context)?.isFirst} isActive : ${ModalRoute.of(context)?.isActive}');
    });
  }

  @override
  void dispose() {
    print('HomeContract dispose');
    super.dispose();
  }

  @override
  void resumeLifeCycle() {
    print('HomeContract resumeLifeCycle');
  }

  @override
  void pauseLifeCycle() {
    print('HomeContract pauseLifeCycle');
  }
}

class HomeView extends ContractView<HomeContract> {
  HomeView(BuildContext context, {Key? key}) : super(context, key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'You have pushed the button this many times:',
                ),
                Text(
                  '${contract.counter}',
                  style: Theme.of(context).textTheme.headline4,
                ),
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return ContractPageBuilder(
                        binder: (_, binder, arguments) {
                          binder.put(ResultCountContract());
                          return true;
                        },
                        builder: (context) => ResultCountView(context),
                      );
                    },)
                    );
                    print('KKH Result : $result');
                  },
                  child: const Text('Result Count'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    context.pushNamed('resultCount');
                  },
                  child: const Text('resultCount'),
                ),
              ],
            ),
          ),
          Expanded(child: ServiceBuilder<FamilyService>(
            builder: (context, service) {
              return ListView(
                children: service
                    .getFamily()
                    .map((e) => ListTile(
                  title: Text(e),
                  onTap: () {
                    context.goNamed('family',
                        params: <String, String>{'fid': e});
                  },
                ))
                    .toList(),
              );
            },
          ))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: contract.incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

/// Family page
class FamilyContract extends Contract {
  final String family;
  late final List<String> persons = FamilyService.instance().getPerson(family);

  FamilyContract(this.family);

  @override
  void init() {
    super.init();
    print('FamilyContract init');
  }

  @override
  void dispose() {
    print('FamilyContract dispose');
    super.dispose();
  }

  @override
  void resumeLifeCycle() {
    print('FamilyContract resumeLifeCycle');
  }

  @override
  void pauseLifeCycle() {
    print('FamilyContract pauseLifeCycle');
  }
}

class FamilyView extends ContractView<FamilyContract> {
  FamilyView(BuildContext context, {Key? key}) : super(context, key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(contract.family),
      ),
      body: ListView(
        children: contract.persons
            .map((e) => ListTile(
          title: Text(e),
          onTap: () {
            context.go(context.namedLocation(
              'person',
              params: <String, String>{
                'fid': contract.family,
                'pid': e
              },
              queryParams: <String, String>{'qid': 'quid'},
            ));
          },
        ))
            .toList(),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

/// Person page
class PersonContract extends Contract {
  final String family;
  final String person;

  PersonContract(this.family, this.person);

  @override
  void init() {
    super.init();
    print('PersonContract init');
  }

  @override
  void dispose() {
    print('PersonContract dispose');
    super.dispose();
  }

  @override
  void resumeLifeCycle() {
    print('PersonContract resumeLifeCycle');
  }

  @override
  void pauseLifeCycle() {
    print('PersonContract pauseLifeCycle');
  }
}

class PersonView extends ContractView<PersonContract> {
  PersonView(BuildContext context, {Key? key}) : super(context, key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(contract.family),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(contract.person),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  Service.of<LoginService>().isLogin = false;
                },
                child: const Text('Log out'),
              ),
            ],
          ),
        ));
  }
}

/// The login screen.
class LoginScreen extends StatelessWidget {
  /// Creates a [LoginScreen].
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Service.of<LoginService>().isLogin = true;
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Result Count
class ResultCountContract extends Contract {
  int _counter = 0;

  int get counter => _counter;

  void incrementCounter() {
    _counter++;
    notifyListeners();
  }

  @override
  void init() {
    super.init();
    print('ResultCountContract init');
  }

  @override
  void dispose() {
    print('ResultCountContract dispose');
    super.dispose();
  }

  @override
  void resumeLifeCycle() {
    print('ResultCountContract resumeLifeCycle');
  }

  @override
  void pauseLifeCycle() {
    print('ResultCountContract pauseLifeCycle');
  }
}

class ResultCountView extends ContractView<ResultCountContract> {
  ResultCountView(BuildContext context, {Key? key}) : super(context, key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ResultCount'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'You have pushed the button this many times:',
                ),
                Text(
                  '${contract.counter}',
                  style: Theme.of(context).textTheme.headline4,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return ContractPageBuilder(
                        binder: (_, binder, arguments) {
                          binder.put(ResultCountNextContract());
                          return true;
                        },
                        builder: (context) => ResultCountNextView(context),
                      );
                    },)
                    );
                  },
                  child: const Text('Next'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(contract.counter);
                },
                child: const Text('Result'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: contract.incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class ResultCountNextContract extends Contract {

  @override
  void init() {
    super.init();
    print('ResultCountNextContract init');
  }

  @override
  void dispose() {
    print('ResultCountNextContract dispose');
    super.dispose();
  }

  @override
  void resumeLifeCycle() {
    print('ResultCountNextContract resumeLifeCycle');
  }

  @override
  void pauseLifeCycle() {
    print('ResultCountNextContract pauseLifeCycle');
  }
}

class ResultCountNextView extends ContractView<ResultCountNextContract> {
  ResultCountNextView(BuildContext context, {Key? key}) : super(context, key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ResultCountNextView'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'ResultCountNextView',
                ),
                ElevatedButton(onPressed: () {
                  Service.of<IsCurrentService>().update();
                }, child: const Text('isCurrent'))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
