import 'package:flutter/material.dart';

@immutable
class CloudStorageExceptions implements Exception {
  const CloudStorageExceptions();
}

class CouldNotCreateNotesException extends CloudStorageExceptions {}

class CouldNotGetAllNoteException extends CloudStorageExceptions {}

class CouldNotUpdateNotesException extends CloudStorageExceptions {}

class CouldNotDeleteNotesException extends CloudStorageExceptions {}
