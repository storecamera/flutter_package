import 'package:example/service/family_service.dart';
import 'package:example/service/login_service.dart';
import 'package:flutter/material.dart';
import 'package:contract/contract.dart';

class PersonContract extends Contract {
  final String family;
  final String person;

  PersonContract(this.family, this.person);
}

class PersonWidget extends ContractWidget<PersonContract> {
  PersonWidget({super.key});

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
            ],
          ),
        ));
  }
}
