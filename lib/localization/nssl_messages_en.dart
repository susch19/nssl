import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

final _keepAnalysisHappy = Intl.defaultLocale;

class MessageLookup extends MessageLookupByLibrary {
  get localeName => 'en';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => {
    "options" : MessageLookupByLibrary.simpleMessage("Options"),
    "changeTheme" : MessageLookupByLibrary.simpleMessage("Change Theme"),
    "scanPB" : MessageLookupByLibrary.simpleMessage("SCAN"),
    "addPB" : MessageLookupByLibrary.simpleMessage("ADD"),
    "searchPB" : MessageLookupByLibrary.simpleMessage("SEARCH"),
    "deleteCrossedOutPB" : MessageLookupByLibrary.simpleMessage("DELETE CROSSED OUT"),
    "addListPB" : MessageLookupByLibrary.simpleMessage("ADD LIST"),
    "contributors" : MessageLookupByLibrary.simpleMessage("Contributors"),
    "rename" : MessageLookupByLibrary.simpleMessage("Rename"),
    "remove" : MessageLookupByLibrary.simpleMessage("Remove"),
    "addProduct" : MessageLookupByLibrary.simpleMessage('Add Product'),
    "addProductWithoutSearch" : MessageLookupByLibrary.simpleMessage('Insert the name of the product, without searching in the database'),
    "productName" : MessageLookupByLibrary.simpleMessage('product name'),
    "messageDeleteAllCrossedOut" : MessageLookupByLibrary.simpleMessage("You have deleted all crossed out items"),
    "undo" : MessageLookupByLibrary.simpleMessage("UNDO"),
    "removedShoppingListMessage" : MessageLookupByLibrary.simpleMessage(" removed"), //"Removed \${User.shoppingLists} "
    "noListsInDrawerMessage" : MessageLookupByLibrary.simpleMessage("here is the place for your lists"),
    "notLoggedInYet" : MessageLookupByLibrary.simpleMessage("Not logged in yet"),
    "newNameOfListHint" : MessageLookupByLibrary.simpleMessage('The new name of the new list'),
    "listName" : MessageLookupByLibrary.simpleMessage('listname'),
    "renameListTitle" : MessageLookupByLibrary.simpleMessage("Rename List"),
    "renameListHint" : MessageLookupByLibrary.simpleMessage('The name of the new list'),
    "addNewListTitle" : MessageLookupByLibrary.simpleMessage("Add new List"),
    "youHaveActionItemMessage" : MessageLookupByLibrary.simpleMessage('You have '), //\$action \$item
    "archived" : MessageLookupByLibrary.simpleMessage('archived'),
    "deleted" : MessageLookupByLibrary.simpleMessage('deleted'),
    "youHaveActionNameMessage" : MessageLookupByLibrary.simpleMessage('You have '), //\$action \${s.name}
    "demoteMenu" : MessageLookupByLibrary.simpleMessage('Demote'),
    "promoteMenu" : MessageLookupByLibrary.simpleMessage('Promote'),
    "contributorUser" : MessageLookupByLibrary.simpleMessage(" - User"),
    "contributorAdmin" : MessageLookupByLibrary.simpleMessage(" - Admin"),
    "genericErrorMessageSnackbar" : MessageLookupByLibrary.simpleMessage("Something went wrong!\n"), //\${z.error}
    "nameOfNewContributorHint" : MessageLookupByLibrary.simpleMessage("Name of new Contributor"),
    "wasRemovedSuccessfullyMessage" : MessageLookupByLibrary.simpleMessage(" was removed successfully"),
    "loginSuccessfullMessage" : MessageLookupByLibrary.simpleMessage("Login successfull."),
    "nameEmailRequiredError" : MessageLookupByLibrary.simpleMessage('Name or Email is required.'),
    "usernameToShortError" : MessageLookupByLibrary.simpleMessage('Your username has to be at least 4 characters long'),
    "emailRequiredError" : MessageLookupByLibrary.simpleMessage('EMail is required.'),
    "emailIncorrectFormatError" : MessageLookupByLibrary.simpleMessage('The email seems to be in the incorrect format.'),
    "chooseAPassword" : MessageLookupByLibrary.simpleMessage('Please choose a password.'),
    "login" : MessageLookupByLibrary.simpleMessage("Login"),
    "usernameOrEmailForLoginHint" : MessageLookupByLibrary.simpleMessage('username or email can be used to login'),
    "usernameOrEmailTitle" : MessageLookupByLibrary.simpleMessage('Username or Email'),
    "emailTitle" : MessageLookupByLibrary.simpleMessage('Email'),
    "choosenPasswordHint" : MessageLookupByLibrary.simpleMessage('the password you have choosen'),
    "password" : MessageLookupByLibrary.simpleMessage('Password'),
    "loginButton" : MessageLookupByLibrary.simpleMessage('LOGIN'),
    "registerTextOnLogin" : MessageLookupByLibrary.simpleMessage("Don't have an account? Create one now."),
    "usernameEmptyError" : MessageLookupByLibrary.simpleMessage("username has to be filled in"),
    "passwordEmptyError" : MessageLookupByLibrary.simpleMessage("password has to be filled in"),
    "emailEmptyError" : MessageLookupByLibrary.simpleMessage("email has to be filled in"),
    "reenterPasswordError" : MessageLookupByLibrary.simpleMessage("passwords doesn't match or are empty"),
    "unknownUsernameError" : MessageLookupByLibrary.simpleMessage("There is something wrong with your username"),
    "unknownEmailError" : MessageLookupByLibrary.simpleMessage("There is something wrong with your email"),
    "unknownPasswordError" : MessageLookupByLibrary.simpleMessage("There is something wrong with your password"),
    "unknownReenterPasswordError" : MessageLookupByLibrary.simpleMessage("There is something wrong with your password validation"),
    "registrationSuccessfulMessage" : MessageLookupByLibrary.simpleMessage("Registration successfull."),
    "registrationTitle" : MessageLookupByLibrary.simpleMessage("Registration."),
    "nameEmptyError" : MessageLookupByLibrary.simpleMessage('Name is required.'),
    "chooseAPasswordPrompt" : MessageLookupByLibrary.simpleMessage('Please choose a password.'),
    "reenterPasswordPrompt" : MessageLookupByLibrary.simpleMessage('Please reenter your password.'),
    "passwordsDontMatchError" : MessageLookupByLibrary.simpleMessage('Passwords don\'t match'),
    "usernameRegisterHint" : MessageLookupByLibrary.simpleMessage('the name to login and to be found by others'),
    "username" : MessageLookupByLibrary.simpleMessage('Username'),
    "emailRegisterHint" : MessageLookupByLibrary.simpleMessage('the email to login and to be found by others'),
    "passwordRegisterHint" : MessageLookupByLibrary.simpleMessage('the password to secure your account'),
    "retypePasswordHint" : MessageLookupByLibrary.simpleMessage('Re-type your password for validation'),
    "retypePasswordTitle" : MessageLookupByLibrary.simpleMessage('Re-type Password'),
    "registerButton" : MessageLookupByLibrary.simpleMessage('REGISTER'),
    "discardNewProduct" : MessageLookupByLibrary.simpleMessage('Discard new product?'),
    "cancelButton" : MessageLookupByLibrary.simpleMessage('CANCEL'),
    "acceptButton" : MessageLookupByLibrary.simpleMessage('ACCEPT'),
    "discardButton" : MessageLookupByLibrary.simpleMessage('DISCARD'),
    "fixErrorsBeforeSubmittingPrompt" : MessageLookupByLibrary.simpleMessage('Please fix the errors in red before submitting.'),
    "newProductTitle" : MessageLookupByLibrary.simpleMessage('New Product'),
    "saveButton" : MessageLookupByLibrary.simpleMessage('SAVE'),
    "newProductName" : MessageLookupByLibrary.simpleMessage("Product Name *"),
    "newProductNameHint" : MessageLookupByLibrary.simpleMessage("How is this product called?"),
    "newProductBrandName" : MessageLookupByLibrary.simpleMessage("Brand Name *"),
    "newProductBrandNameHint" : MessageLookupByLibrary.simpleMessage("Which company sells this product?"),
    "newProductWeight" : MessageLookupByLibrary.simpleMessage("Amount with Unit"),
    "newProductWeightHint" : MessageLookupByLibrary.simpleMessage("Example: 1.5l or 100g"),
    "newProductAddToList" : MessageLookupByLibrary.simpleMessage("Add to current list"),
    "newProductStarExplanation" : MessageLookupByLibrary.simpleMessage('* indicates required field'),
    "fieldRequiredError" : MessageLookupByLibrary.simpleMessage("This field is required!"),
    "newProductNameToShort" : MessageLookupByLibrary.simpleMessage("This name seems to be to short"),
    "addedProduct" : MessageLookupByLibrary.simpleMessage(' added'), //'Added "\$name"'
    "productWasAlreadyInList" : MessageLookupByLibrary.simpleMessage(' was already in list. The amount was increased by 1'), //"\$name" was
    "searchProductHint" : MessageLookupByLibrary.simpleMessage("Search Product"),
    "noMoreProductsMessage" : MessageLookupByLibrary.simpleMessage("No more products found!}"),
    "codeText" : MessageLookupByLibrary.simpleMessage("Code: "),
    "removed" : MessageLookupByLibrary.simpleMessage("removed"),
    "changePrimaryColor" : MessageLookupByLibrary.simpleMessage("Primary Color"),
    "changeAccentColor" : MessageLookupByLibrary.simpleMessage("Accent Color"),
    "changeDarkTheme" : MessageLookupByLibrary.simpleMessage("Dark Theme"),
    "changeAccentTextColor" : MessageLookupByLibrary.simpleMessage("Bright Icons"),


  };
}