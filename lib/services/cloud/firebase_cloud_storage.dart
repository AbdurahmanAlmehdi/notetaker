import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notetaker/services/cloud/cloud_note.dart';
import 'package:notetaker/services/cloud/cloud_storage_constants.dart';
import 'package:notetaker/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');

  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete;
    } catch (e) {
      throw CouldNotDeleteNotesException();
    }
  }

  Future<void> updateNote({
    required String documentId,
    required String text,
  }) async {
    try {
      await notes.doc(documentId).update({textFieldName: text});
    } catch (e) {
      throw CouldNotUpdateNotesException();
    }
  }

  Stream<Iterable<CloudNote>> allNotes(String ownerUserId) =>
      notes.snapshots().map((events) => events.docs
          .map((doc) => CloudNote.fromSnapshot(doc))
          .where((note) => note.documentId == ownerUserId));

  Future<Iterable<CloudNote>> getNotes({required ownerUserId}) async {
    try {
      return await notes
          .where(
            ownerUserIdFieldName,
            isEqualTo: ownerUserId,
          )
          .get()
          .then(
            (values) => values.docs.map(
              (doc) {
                return CloudNote(
                  documentId: doc.id,
                  ownerUserId: doc.data()[ownerUserIdFieldName] as String,
                  text: doc.data()[textFieldName],
                );
              },
            ),
          );
    } catch (e) {
      throw CouldNotGetAllNoteException();
    }
  }

  Future<void> createNewNote({required String ownerUserId}) async {
    await notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
    });
  }

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
