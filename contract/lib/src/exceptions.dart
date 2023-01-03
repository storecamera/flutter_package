enum ContractExceptions {
  notFoundContract,
  notFoundContractAtBuilder,
  notFoundContractBinder,
  notFoundContractContext,
  notFoundService,
  notFoundServiceAtBuilder,
  invalidArguments,
}

extension ContractExceptionsExtension on ContractExceptions {
  ContractException get exception => ContractException(this);
}

class ContractException implements Exception  {
  final ContractExceptions exception;

  ContractException(this.exception);

  @override
  String toString() {
    return 'ContractException{exception: $exception}';
  }
}
