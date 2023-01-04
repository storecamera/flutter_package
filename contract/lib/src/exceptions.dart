class ContractException implements Exception {
  final String message;

  const ContractException(this.message);

  @override
  String toString() {
    return '$runtimeType {message: $message}';
  }
}

/// Find error
class ContractExceptionNotFoundBinderFromParent extends ContractException {
  const ContractExceptionNotFoundBinderFromParent()
      : super('Could not find BinderContract from parent');
}

class ContractExceptionNotFoundBinder extends ContractException {
  const ContractExceptionNotFoundBinder(Type runtimeType)
      : super(
            'A BinderContract of this $runtimeType was not found in the parent');
}

class ContractExceptionNotFoundContract extends ContractException {
  const ContractExceptionNotFoundContract(Type runtimeType)
      : super(
            'A Contract of this $runtimeType was not found in the parent');
}

class ContractExceptionNotFoundService extends ContractException {
  const ContractExceptionNotFoundService(Type runtimeType)
      : super(
      'A Service of this $runtimeType was not found');
}

/// Context error
class ContractExceptionContext extends ContractException {
  const ContractExceptionContext(Type runtimeType)
      : super(
      'This $runtimeType does not have a context');
}

/// Value
class ContractExceptionValueStatus extends ContractException {
  const ContractExceptionValueStatus(String message)
      : super(message);
}

/// AsyncWorker
class ContractExceptionAsyncWorkerDisposed extends ContractException {
  const ContractExceptionAsyncWorkerDisposed(Type runtimeType, String function)
      : super(
            'This $runtimeType:$function was disposed, consider checking `isDisposed`');
}

class ContractExceptionInvalidArguments extends ContractException {
  const ContractExceptionInvalidArguments()
      : super(
      'Invalid arguments');
}