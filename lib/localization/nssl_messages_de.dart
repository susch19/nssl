import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

final _keepAnalysisHappy = Intl.defaultLocale;

class MessageLookup extends MessageLookupByLibrary {
  get localeName => 'de';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => {
    "options" : MessageLookupByLibrary.simpleMessage("Optionen"),
    "scanPB" : MessageLookupByLibrary.simpleMessage("SCANNEN"),
    "addPB" : MessageLookupByLibrary.simpleMessage("ADD"), //TODO find good german word
    "searchPB" : MessageLookupByLibrary.simpleMessage("SUCHEN"),
    "deletecrossedoutPB" : MessageLookupByLibrary.simpleMessage("LÖSCHE MAKIERTE"),
    "addlistPB" : MessageLookupByLibrary.simpleMessage("LISTE HINZUFÜGEN"),
    "contributors" : MessageLookupByLibrary.simpleMessage("Teilnehmer"),
    "rename" : MessageLookupByLibrary.simpleMessage("Umbenennen"),
    "remove" : MessageLookupByLibrary.simpleMessage("Entfernen"),
  };
}