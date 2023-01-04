import 'package:example/service/family_service.dart';
import 'package:flutter/material.dart';
import 'package:contract/contract.dart';

class FamilyPage extends ContractPage {
  const FamilyPage({super.key, super.arguments});

  @override
  BinderContract createBinder() => FamilyBinder();

  @override
  Widget build(BuildContext context) => FamilyWidget();
}

class FamilyBinder extends BinderContract {

  late final String family;
  late final List<String> persons;

  @override
  void onInit() {
    super.onInit();

    final arguments = this.arguments;
    if(arguments is String) {
      family = arguments;
      persons = FamilyService.instance.getPerson(family);
    } else {
      throw ContractExceptions.invalidArguments.exception;
    }
  }
}

class FamilyWidget extends ContractWidget<FamilyBinder> {
  FamilyWidget({super.key});

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
            Navigator.of(context).pushNamed('/person', arguments: {
              'family': contract.family,
              'person': e
            });
          },
        ))
            .toList(),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
