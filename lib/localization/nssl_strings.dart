
import 'dart:async';

import 'package:intl/intl.dart';
import 'package:flutter/widgets.dart';
import 'package:nssl/localization/nssl_messages_all.dart';

class NSSLStrings {
  NSSLStrings(Locale locale) : _localeName = locale.toString();

  final String _localeName;

  static Future<NSSLStrings> load(Locale locale) {
    return initializeMessages(locale.toString())
        .then((dynamic _) {
      // ignore: strong_mode_uses_dynamic_as_bottom
      return new NSSLStrings(locale);
    });
  }

  static NSSLStrings of(BuildContext context) {
    return Localizations.of<NSSLStrings>(context, NSSLStrings);
  }
 // static final NSSLStrings instance = new NSSLStrings();

  String options() => Intl.message('Options', name: 'options', locale:_localeName);
  String changeTheme() => Intl.message('Change Theme', name: 'changeTheme', locale:_localeName);
  String scanPB() => Intl.message('SCAN', name: 'scanPB', locale:_localeName);
  String addPB() => Intl.message('ADD', name: 'addPB', locale:_localeName);
  String searchPB() => Intl.message('SEARCH', name: 'searchPB', locale:_localeName);
  String deleteCrossedOutPB() => Intl.message('DELETE CROSSED OUT', name: 'deleteCrossedOutPB', locale:_localeName);
  String addListPB() => Intl.message('ADD LIST', name: 'addListPB', locale:_localeName);
  String contributors() => Intl.message('Contributors', name: 'contributors', locale:_localeName);
  String rename() => Intl.message('Rename', name: 'rename', locale:_localeName);
  String remove() => Intl.message('Remove', name: 'remove', locale:_localeName);
  String addProduct() => Intl.message('Add Product', name: 'addProduct', locale:_localeName);
  String addProductWithoutSearch() => Intl.message('Insert the name of the product, without searching in the database', name: 'addProductWithoutSearch', locale:_localeName);
  String productName() => Intl.message('Product name', name: 'productName', locale:_localeName);
  String messageDeleteAllCrossedOut() => Intl.message('You have deleted all crossed out items', name: 'messageDeleteAllCrossedOut', locale:_localeName);
  String undo() => Intl.message('UNDO', name: 'undo', locale:_localeName);
  String noListsInDrawerMessage() => Intl.message('Here is the place for your lists', name: 'noListsInDrawerMessage', locale:_localeName);
  String notLoggedInYet() => Intl.message('Not logged in yet', name: 'notLoggedInYet', locale:_localeName);
  String newNameOfListHint() => Intl.message('The new name of the new list', name: 'newNameOfListHint', locale:_localeName);
  String listName() => Intl.message('Listname', name: 'listName', locale:_localeName);
  String renameListTitle() => Intl.message('Rename List', name: 'renameListTitle', locale:_localeName);
  String renameListHint() => Intl.message('The name of the new list', name: 'renameListHint', locale:_localeName);
  String addNewListTitle() => Intl.message('Add new List', name: 'addNewListTitle', locale:_localeName);
  String youHaveActionItemMessage() => Intl.message('You have ', name: 'youHaveActionItemMessage', locale:_localeName);
  String archived() => Intl.message('archived', name: 'archived', locale:_localeName);
  String deleted() => Intl.message('deleted', name: 'deleted', locale:_localeName);
  String youHaveActionNameMessage() => Intl.message('You have ', name: 'youHaveActionNameMessage', locale:_localeName);
  String demoteMenu() => Intl.message('Demote', name: 'demoteMenu', locale:_localeName);
  String promoteMenu() => Intl.message('Promote', name: 'promoteMenu', locale:_localeName);
  String contributorUser() => Intl.message(" - User", name: 'contributorUser', locale:_localeName);
  String contributorAdmin() => Intl.message(" - Admin", name: 'contributorAdmin', locale:_localeName);
  String genericErrorMessageSnackbar() => Intl.message('Something went wrong!\n', name: 'genericErrorMessageSnackbar', locale:_localeName);
  String nameOfNewContributorHint() => Intl.message('Name of new Contributor', name: 'nameOfNewContributorHint', locale:_localeName);
  String wasRemovedSuccessfullyMessage() => Intl.message(' was removed successfully', name: 'wasRemovedSuccessfullyMessage', locale:_localeName);
  String loginSuccessfulMessage() => Intl.message('Login successfull.', name: 'loginSuccessfullMessage', locale:_localeName);
  String nameEmailRequiredError() => Intl.message('Name or Email is required.', name: 'nameEmailRequiredError', locale:_localeName);
  String usernameToShortError() => Intl.message('Your username has to be at least 4 characters long', name: 'usernameToShortError', locale:_localeName);
  String emailRequiredError() => Intl.message('EMail is required.', name: 'emailRequiredError', locale:_localeName);
  String emailIncorrectFormatError() => Intl.message('The email seems to be in the incorrect format.', name: 'emailIncorrectFormatError', locale:_localeName);
  String chooseAPassword() => Intl.message('Please choose a password.', name: 'chooseAPassword', locale:_localeName);
  String login() => Intl.message('Login', name: 'login', locale:_localeName);
  String usernameOrEmailForLoginHint() => Intl.message('Username or email can be used to login', name: 'usernameOrEmailForLoginHint', locale:_localeName);
  String usernameOrEmailTitle() => Intl.message('Username or Email', name: 'usernameOrEmailTitle', locale:_localeName);
  String emailTitle() => Intl.message('Email', name: 'emailTitle', locale:_localeName);
  String choosenPasswordHint() => Intl.message('The password you have choosen', name: 'choosenPasswordHint', locale:_localeName);
  String password() => Intl.message('Password', name: 'password', locale:_localeName);
  String loginButton() => Intl.message('LOGIN', name: 'loginButton', locale:_localeName);
  String registerTextOnLogin() => Intl.message('Don\'t have an account? Create one now.', name: 'registerTextOnLogin', locale:_localeName);
  String usernameEmptyError() => Intl.message('Username has to be filled in', name: 'usernameEmptyError', locale:_localeName);
  String passwordEmptyError() => Intl.message('Password has to be filled in', name: 'passwordEmptyError', locale:_localeName);
  String emailEmptyError() => Intl.message('Email has to be filled in', name: 'emailEmptyError', locale:_localeName);
  String reenterPasswordError() => Intl.message('Passwords doesn\'t match or are empty', name: 'reenterPasswordError', locale:_localeName);
  String unknownUsernameError() => Intl.message('There is something wrong with your username', name: 'unknownUsernameError', locale:_localeName);
  String unknownEmailError() => Intl.message('There is something wrong with your email', name: 'unknownEmailError', locale:_localeName);
  String unknownPasswordError() => Intl.message('There is something wrong with your password', name: 'unknownPasswordError', locale:_localeName);
  String unknownReenterPasswordError() => Intl.message('There is something wrong with your password validation', name: 'unknownReenterPasswordError', locale:_localeName);
  String registrationSuccessfulMessage() => Intl.message('Registration successfull.', name: 'registrationSuccessfullMessage', locale:_localeName);
  String registrationTitle() => Intl.message('Registration', name: 'registrationTitle', locale:_localeName);
  String nameEmptyError() => Intl.message('Name is required.', name: 'nameEmptyError', locale:_localeName);
  String chooseAPasswordPrompt() => Intl.message('Please choose a password.', name: 'chooseAPasswordPrompt', locale:_localeName);
  String reenterPasswordPrompt() => Intl.message('Please reenter your password.', name: 'reenterPasswordPromt', locale:_localeName);
  String passwordsDontMatchError() => Intl.message('Passwords don\'t match', name: 'passwordsDontMatchError', locale:_localeName);
  String usernameRegisterHint() => Intl.message('The name to login and to be found by others', name: 'usernameRegisterHint', locale:_localeName);
  String username() => Intl.message('Username', name: 'username', locale:_localeName);
  String emailRegisterHint() => Intl.message('The email to login and to be found by others', name: 'emailRegisterHint', locale:_localeName);
  String passwordRegisterHint() => Intl.message('The password to secure your account', name: 'passwordRegisterHint', locale:_localeName);
  String retypePasswordHint() => Intl.message('Re-type your password for validation', name: 'retypePasswordHint', locale:_localeName);
  String retypePasswordTitle() => Intl.message('Re-type Password', name: 'retypePasswordTitle', locale:_localeName);
  String registerButton() => Intl.message('REGISTER', name: 'registerButton', locale:_localeName);
  String discardNewProduct() => Intl.message('Discard new product?', name: 'discardNewProduct', locale:_localeName);
  String cancelButton() => Intl.message('CANCEL', name: 'cancelButton', locale:_localeName);
  String acceptButton() => Intl.message('ACCEPT', name: 'acceptButton', locale:_localeName);
  String discardButton() => Intl.message('DISCARD', name: 'discardButton', locale:_localeName);
  String fixErrorsBeforeSubmittingPrompt() => Intl.message('Please fix the errors in red before submitting.', name: 'fixErrorsBeforeSubmittingPrompt', locale:_localeName);
  String newProductTitle() => Intl.message('New Product', name: 'newProductTitle', locale:_localeName);
  String saveButton() => Intl.message('SAVE', name: 'saveButton', locale:_localeName);
  String newProductName() => Intl.message('Product Name *', name: 'newProductName', locale:_localeName);
  String newProductNameHint() => Intl.message('How is this product called?', name: 'newProductNameHint', locale:_localeName);
  String newProductBrandName() => Intl.message('Brand Name *', name: 'newProductBrandName', locale:_localeName);
  String newProductBrandNameHint() => Intl.message('Which company sells this product?', name: 'newProductBrandNameHint', locale:_localeName);
  String newProductWeight() => Intl.message('Weight', name: 'newProductWeight', locale:_localeName);
  String newProductWeightHint() => Intl.message('What is the normal packaging size?', name: 'newProductWeightHint', locale:_localeName);
  String newProductAddToList() => Intl.message('Add to current list', name: 'newProductAddToList', locale:_localeName);
  String newProductStarExplanation() => Intl.message('* indicates required field', name: 'newProductStarExplanation', locale:_localeName);
  String fieldRequiredError() => Intl.message('This field is required!', name: 'fieldRequiredError', locale:_localeName);
  String newProductNameToShort() => Intl.message('This name seems to be to short', name: 'newProductNameToShort', locale:_localeName);
  String addedProduct() => Intl.message(' added', name: 'addedProduct', locale:_localeName);
  String productWasAlreadyInList() => Intl.message(' was already in list. The amount was increased by 1', name: 'productWasAlreadyInList', locale:_localeName);
  String searchProductHint() => Intl.message('Search Product', name: 'searchProductHint', locale:_localeName);
  String noMoreProductsMessage() => Intl.message('No more products found!', name: 'noMoreProductsMessage', locale:_localeName);
  String codeText() => Intl.message('Code: ', name: 'codeText', locale:_localeName);
  String removed() => Intl.message('removed', name: 'removed', locale:_localeName);
  String changePrimaryColor() => Intl.message('Primary Color', name: 'changePrimaryColor', locale:_localeName);
  String changeAccentColor() => Intl.message('Accent Color', name: 'changeAccentColor', locale:_localeName);
  String changeDarkTheme() => Intl.message('Dark Theme', name: 'changeDarkTheme', locale:_localeName);
  String changeAccentTextColor() => Intl.message('Dark Icons', name: 'changeAccentTextColor', locale:_localeName);
  String autoSync() => Intl.message('Auto-Sync', name: 'autoSync', locale:_localeName);
  String changePasswordButton() => Intl.message('CHANGE PASSWORD', name: 'changePasswordButton', locale:_localeName);
  String oldPassword() => Intl.message('Current password', name: 'currentPassword', locale:_localeName);
  String oldPasswordHint() => Intl.message('Current password that should be changed', name: 'currentPasswordHint', locale:_localeName);
  String newPassword() => Intl.message('New password', name: 'newPassword', locale:_localeName);
  String newPasswordHint() => Intl.message('The new password you have chosen', name: 'newPasswordHint', locale:_localeName);
  String new2Password() => Intl.message('Repeat new password', name: 'repeatNewPassword', locale:_localeName);
  String new2PasswordHint() => Intl.message('repeat the new password you have chosen', name: 'repeatNewPasswordHint', locale:_localeName);
  String changePasswordPD() => Intl.message('Change Password', name: 'changePasswordPD', locale:_localeName);
  String successful() => Intl.message('Successful', name: 'successful', locale:_localeName);
  String passwordSet() => Intl.message('Your password has been set', name: 'passwordSet', locale:_localeName);
  String tokenExpired() => Intl.message('Token expired', name: 'tokenExpired', locale:_localeName);
  String tokenExpiredExplanation() => Intl.message('Your token has expired. Login is required. If this happends multiple times per month, please contact us.', name: 'tokenExpiredExplanation', locale:_localeName);
  String noListLoaded() => Intl.message('No List Loaded', name: 'noListLoaded', locale:_localeName);
  String renameListItem() => Intl.message('Rename Product', name: 'renameListItem', locale:_localeName);
  String renameListItemHint() => Intl.message('The new name of the product', name: 'renameListItemHint', locale:_localeName);
  String renameListItemLabel() => Intl.message('new product name', name: 'renameListItemLabel', locale:_localeName);
  String discardNewTheme() => Intl.message('Discard new theme?', name: 'discardNewTheme', locale:_localeName);
  String forgotPassword() => Intl.message('Forgot password?', name: 'forgotPassword', locale:_localeName);
  String bePatient() => Intl.message('Please be patient, the server is processing your request already', name: 'bePatient', locale:_localeName);
  String logout() => Intl.message('Logout', name: 'logout', locale:_localeName);
  String deleteListTitle() => Intl.message('Delete List', name: 'deleteListTitle', locale:_localeName);
  String deleteListText() => Intl.message('Do you really want to delete the list? This CAN\'T be undone!', name: 'deleteListText', locale:_localeName);
  String exportAsPdf() => Intl.message('Export as PDF', name: 'exportAsPdf', locale:_localeName);
  String boughtProducts() => Intl.message('Bought Products', name: 'boughtProducts', locale:_localeName);
  String nothingBoughtYet() => Intl.message('Nothing bought yet', name: 'nothingBoughtYet', locale:_localeName);
  //String openAppDrawerTooltip() => Intl.message('Open navigation menu', name: 'openNavigationMenu', locale: _localeName);


}
