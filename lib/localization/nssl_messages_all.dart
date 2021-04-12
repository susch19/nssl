import 'dart:async';

import 'package:intl/intl.dart';
import 'package:intl/src/intl_helpers.dart';
import 'package:intl/message_lookup_by_library.dart';
import 'package:nssl/localization/nssl_messages_de.dart' as m_de;
import 'package:nssl/localization/nssl_messages_en.dart' as m_en;

Map<String, Function> _deferredLibraries = {
  'en': () => Future.value(null),
  'de': () => Future.value(null),
  'es': () => Future.value(null),
};

MessageLookupByLibrary _findExact(localeName) {
  switch (localeName) {
    case 'en':
      return m_en.messages;
    case 'es':
      return null; //messages_es.messages;
    case 'de':
      return m_de.messages;
    default:
      return null;
  }
}

/// User programs should call this before using [localeName] for messages.
Future initializeMessages(String localeName) {
  var lib = _deferredLibraries[Intl.canonicalizedLocale(localeName)];
  var load = lib == null ? Future.value(false) : Future.value(null);
  return load.then((_) {
    initializeInternalMessageLookup(() => CompositeMessageLookup());
    messageLookup.addLocale(localeName, _findGeneratedMessagesFor);
  });
}

bool _messagesExistFor(String locale) {
  var messages;
  try {
    messages = _findExact(locale);
  } catch (e) {}
  return messages != null;
}

MessageLookupByLibrary _findGeneratedMessagesFor(locale) {
  var actualLocale =
      Intl.verifiedLocale(locale, _messagesExistFor, onFailure: (_) => null);
  if (actualLocale == null) return null;
  return _findExact(actualLocale);
}
