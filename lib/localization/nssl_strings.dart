// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:intl/intl.dart';
import 'package:flutter/widgets.dart';

// Wrappers for strings that are shown in the UI.  The strings can be
// translated for different locales using the Dart intl package.
//
// Locale-specific values for the strings live in the i18n/*.arb files.
//
// To generate the stock_messages_*.dart files from the ARB files, run:
//   pub run intl:generate_from_arb --output-dir=lib/i18n --generated-file-prefix=stock_ --no-use-deferred-loading lib/stock_strings.dart lib/i18n/stocks_*.arb

class NSSLStrings extends LocaleQueryData {
  static NSSLStrings of(BuildContext context) {
    return LocaleQuery.of(context);
  }

  static final NSSLStrings instance = new NSSLStrings();

  String options() => Intl.message('Options', name: 'options');
  String scanPB() => Intl.message('SCAN', name: 'scanPB');
  String addPB() => Intl.message('ADD', name: 'addPB');
  String searchPB() => Intl.message('SEARCH', name: 'searchPB');
  String deletecrossedoutPB() =>
      Intl.message('DELETE CROSSED OUT', name: 'deletecrossedoutPB');
  String addlistPB() => Intl.message('ADD LIST', name: 'addlistPB');
  String contributors() => Intl.message('Contributors', name: 'contributors');
  String rename() => Intl.message('Rename', name: 'rename');
  String remove() => Intl.message('Remove', name: 'remove');
}
