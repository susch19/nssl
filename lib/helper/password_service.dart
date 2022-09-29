enum PasswordErrorCode { none, empty, tooShort, missingCharacters }

class PasswordService {
  static PasswordErrorCode checkNewPassword(String newPassword) {
    if (newPassword.isEmpty) return PasswordErrorCode.empty;
    if (newPassword.length < 6) return PasswordErrorCode.tooShort;
    var containsChar = newPassword.contains(RegExp(r'[a-zA-ZäöüÄÖÜ]'));
    var containsDigit = newPassword.contains(RegExp(r'[0-9]'));
    var containsSpecialChar = newPassword.contains(RegExp(r'[^0-9a-zA-ZäöüÄÖÜ]'));
    if (!containsChar && !containsSpecialChar || !containsDigit && !containsSpecialChar)
      return PasswordErrorCode.missingCharacters;

    return PasswordErrorCode.none;
  }
}
