import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

final _keepAnalysisHappy = Intl.defaultLocale;

class MessageLookup extends MessageLookupByLibrary {
  get localeName => 'en';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => {
    "options" : MessageLookupByLibrary.simpleMessage("Options"),
    "scanPB" : MessageLookupByLibrary.simpleMessage("SCAN"),
    "addPB" : MessageLookupByLibrary.simpleMessage("ADD"),
    "searchPB" : MessageLookupByLibrary.simpleMessage("SEARCH"),
    "deletecrossedoutPB" : MessageLookupByLibrary.simpleMessage("DELETE CROSSED OUT"),
    "addlistPB" : MessageLookupByLibrary.simpleMessage("ADD LIST"),
    "contributors" : MessageLookupByLibrary.simpleMessage("Contributors"),
    "rename" : MessageLookupByLibrary.simpleMessage("Rename"),
    "remove" : MessageLookupByLibrary.simpleMessage("Remove"),
    /*"options" : MessageLookupByLibrary.simpleMessage("Options"),
    "options" : MessageLookupByLibrary.simpleMessage("Options"),
    "options" : MessageLookupByLibrary.simpleMessage("Options"),
    "options" : MessageLookupByLibrary.simpleMessage("Options"),
    "options" : MessageLookupByLibrary.simpleMessage("Options"),
    "options" : MessageLookupByLibrary.simpleMessage("Options"),
    "options" : MessageLookupByLibrary.simpleMessage("Options")*/
  };
}