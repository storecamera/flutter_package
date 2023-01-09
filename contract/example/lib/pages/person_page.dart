import 'package:flutter/material.dart';
import 'package:contract/contract.dart';

class PersonContract extends Contract with AsyncWorker {
  final String family;
  final String person;

  PersonContract(this.family, this.person);

  @override
  void onInit() {
    super.onInit();
    asyncWorker(() async {
      await Future.delayed(const Duration(milliseconds: 3000));
    });
  }
}

class PersonWidget extends ContractWidget<PersonContract> {
  PersonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AsyncWorkerWidget(
      worker: contract,
      child: Scaffold(
          appBar: AppBar(
            title: Text(contract.family),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextButton(onPressed: () {
                  showDialog(context: context, builder: (context) {
                    return const AlertDialog(content: Text('Simple dialog'),);
                  });
                }, child: Text(contract.person)),
              ],
            ),
          )),
    );
  }
}
