import 'package:example/service/family_service.dart';
import 'package:flutter/material.dart';
import 'package:contract/contract.dart';

class HomeFamilyWidget extends ContractWidget<FamilyService> {
  HomeFamilyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        children: contract.getFamily().map((e) {
          return ListTile(
            title: Text(e),
            onTap: () {
              Navigator.of(context).pushNamed('/family', arguments: e);
            },
          );
        }).toList(),
      ),
    );
  }
}
