import 'package:cloud_firestore/cloud_firestore.dart';

abstract class FirestoreCollection {
  String get path;
}

class FirestoreCollectionKey implements FirestoreCollection {
  @override
  final String path;

  const FirestoreCollectionKey(this.path);
}

extension FireStoreExtension on FirestoreCollection {
  CollectionReference<Map<String, dynamic>> get collection =>
      FirebaseFirestore.instance.collection(path);

  DocumentReference<Map<String, dynamic>> doc([String? path]) =>
      collection.doc(path);
}
