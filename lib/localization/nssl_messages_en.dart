import 'package:intl/message_lookup_by_library.dart';

final messages = MessageLookup();

class MessageLookup extends MessageLookupByLibrary {
  get localeName => 'en';

  final Map<String, dynamic> messages =
      _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => {
        "options": MessageLookupByLibrary.simpleMessage("Options"),
        "changeTheme": MessageLookupByLibrary.simpleMessage("Change Theme"),
        "scanPB": MessageLookupByLibrary.simpleMessage("SCAN"),
        "addPB": MessageLookupByLibrary.simpleMessage("ADD"),
        "searchPB": MessageLookupByLibrary.simpleMessage("SEARCH"),
        "deleteCrossedOutPB":
            MessageLookupByLibrary.simpleMessage("Delete crossed out"),
        "addListPB": MessageLookupByLibrary.simpleMessage("ADD LIST"),
        "contributors": MessageLookupByLibrary.simpleMessage("Contributors"),
        "rename": MessageLookupByLibrary.simpleMessage("Rename"),
        "remove": MessageLookupByLibrary.simpleMessage("Remove"),
        "addProduct": MessageLookupByLibrary.simpleMessage('Add Product'),
        "addProductWithoutSearch": MessageLookupByLibrary.simpleMessage(
            'Insert the name of the product, without searching in the database'),
        "productName": MessageLookupByLibrary.simpleMessage('product name'),
        "messageDeleteAllCrossedOut": MessageLookupByLibrary.simpleMessage(
            "You have deleted all crossed out items"),
        "undo": MessageLookupByLibrary.simpleMessage("UNDO"),
        "removedShoppingListMessage": MessageLookupByLibrary.simpleMessage(
            " removed"), //"Removed \${User.shoppingLists} "
        "noListsInDrawerMessage": MessageLookupByLibrary.simpleMessage(
            "here is the place for your lists"),
        "notLoggedInYet":
            MessageLookupByLibrary.simpleMessage("Not logged in yet"),
        "newNameOfListHint": MessageLookupByLibrary.simpleMessage(
            'The new name of the new list'),
        "listName": MessageLookupByLibrary.simpleMessage('listname'),
        "renameListTitle": MessageLookupByLibrary.simpleMessage("Rename List"),
        "renameListHint":
            MessageLookupByLibrary.simpleMessage('The name of the new list'),
        "chooseListToAddTitle":
            MessageLookupByLibrary.simpleMessage('Which list to add?'),
        "addNewListTitle": MessageLookupByLibrary.simpleMessage("Add new List"),
        "recipeCreateError":
            MessageLookupByLibrary.simpleMessage("Could not create recipe"),
        "recipeFromShareTitle":
            MessageLookupByLibrary.simpleMessage("To which list to add?"),
        "recipeFromShareNew": MessageLookupByLibrary.simpleMessage("NEW"),
        "recipeName": MessageLookupByLibrary.simpleMessage("Recipe"),
        "recipeNameHint":
            MessageLookupByLibrary.simpleMessage("Recipe ID or URL"),
        "addNewRecipeTitle":
            MessageLookupByLibrary.simpleMessage("Add new recipe"),
        "importNewRecipe":
            MessageLookupByLibrary.simpleMessage("Import recipe"),
        "importNewRecipeTitle":
            MessageLookupByLibrary.simpleMessage("Import new recipe"),
        "chooseAddListDialog":
            MessageLookupByLibrary.simpleMessage("Shoppinglist"),
        "chooseAddRecipeDialog":
            MessageLookupByLibrary.simpleMessage("Chefkoch Recipe"),
        "youHaveActionItemMessage":
            MessageLookupByLibrary.simpleMessage('You have '), //\$action \$item
        "archived": MessageLookupByLibrary.simpleMessage('archived'),
        "deleted": MessageLookupByLibrary.simpleMessage('deleted'),
        "youHaveActionNameMessage": MessageLookupByLibrary.simpleMessage(
            'You have '), //\$action \${s.name}
        "demoteMenu": MessageLookupByLibrary.simpleMessage('Demote'),
        "promoteMenu": MessageLookupByLibrary.simpleMessage('Promote'),
        "contributorUser": MessageLookupByLibrary.simpleMessage(" - User"),
        "contributorAdmin": MessageLookupByLibrary.simpleMessage(" - Admin"),
        "genericErrorMessageSnackbar": MessageLookupByLibrary.simpleMessage(
            "Something went wrong!\n"), //\${z.error}
        "nameOfNewContributorHint":
            MessageLookupByLibrary.simpleMessage("Name of new Contributor"),
        "wasRemovedSuccessfullyMessage":
            MessageLookupByLibrary.simpleMessage(" was removed successfully"),
        "loginSuccessfullMessage":
            MessageLookupByLibrary.simpleMessage("Login successfull."),
        "nameEmailRequiredError":
            MessageLookupByLibrary.simpleMessage('Name or Email is required.'),
        "usernameToShortError": MessageLookupByLibrary.simpleMessage(
            'Your username has to be at least 4 characters long'),
        "emailRequiredError":
            MessageLookupByLibrary.simpleMessage('EMail is required.'),
        "emailIncorrectFormatError": MessageLookupByLibrary.simpleMessage(
            'The email seems to be in the incorrect format.'),
        "chooseAPassword":
            MessageLookupByLibrary.simpleMessage('Please choose a password.'),
        "login": MessageLookupByLibrary.simpleMessage("Login"),
        "usernameOrEmailForLoginHint": MessageLookupByLibrary.simpleMessage(
            'Username or email can be used to login'),
        "usernameOrEmailTitle":
            MessageLookupByLibrary.simpleMessage('Username or Email'),
        "emailTitle": MessageLookupByLibrary.simpleMessage('Email'),
        "choosenPasswordHint": MessageLookupByLibrary.simpleMessage(
            'The password you have choosen'),
        "password": MessageLookupByLibrary.simpleMessage('Password'),
        "loginButton": MessageLookupByLibrary.simpleMessage('LOGIN'),
        "registerTextOnLogin": MessageLookupByLibrary.simpleMessage(
            "Don't have an account? Create one now."),
        "usernameEmptyError": MessageLookupByLibrary.simpleMessage(
            "Username has to be filled in"),
        "passwordEmptyError": MessageLookupByLibrary.simpleMessage(
            "Password has to be filled in"),
        "passwordTooShortError": MessageLookupByLibrary.simpleMessage(
            "Password has to be at least 6 charactes long"),
        "passwordMissingCharactersError": MessageLookupByLibrary.simpleMessage(
            "Password has to contain a special character (Can be emoji or any other symbol) and a letter or number"),
        "emailEmptyError":
            MessageLookupByLibrary.simpleMessage("Email has to be filled in"),
        "reenterPasswordError": MessageLookupByLibrary.simpleMessage(
            "Passwords doesn't match or are empty"),
        "unknownUsernameError": MessageLookupByLibrary.simpleMessage(
            "There is something wrong with your username"),
        "unknownEmailError": MessageLookupByLibrary.simpleMessage(
            "There is something wrong with your email"),
        "unknownPasswordError": MessageLookupByLibrary.simpleMessage(
            "There is something wrong with your password"),
        "unknownReenterPasswordError": MessageLookupByLibrary.simpleMessage(
            "There is something wrong with your password validation"),
        "registrationSuccessfulMessage":
            MessageLookupByLibrary.simpleMessage("Registration successfull."),
        "registrationTitle":
            MessageLookupByLibrary.simpleMessage("Registration"),
        "nameEmptyError":
            MessageLookupByLibrary.simpleMessage('Name is required.'),
        "chooseAPasswordPrompt":
            MessageLookupByLibrary.simpleMessage('Please choose a password.'),
        "reenterPasswordPrompt": MessageLookupByLibrary.simpleMessage(
            'Please reenter your password.'),
        "passwordsDontMatchError":
            MessageLookupByLibrary.simpleMessage('Passwords don\'t match'),
        "usernameRegisterHint": MessageLookupByLibrary.simpleMessage(
            'The name to login and to be found by others'),
        "username": MessageLookupByLibrary.simpleMessage('Username'),
        "emailRegisterHint": MessageLookupByLibrary.simpleMessage(
            'The email to login and to be found by others'),
        "passwordRegisterHint": MessageLookupByLibrary.simpleMessage(
            'The password to secure your account'),
        "retypePasswordHint": MessageLookupByLibrary.simpleMessage(
            'Re-type your password for validation'),
        "retypePasswordTitle":
            MessageLookupByLibrary.simpleMessage('Re-type Password'),
        "registerButton": MessageLookupByLibrary.simpleMessage('REGISTER'),
        "discardNewProduct":
            MessageLookupByLibrary.simpleMessage('Discard new product?'),
        "cancelButton": MessageLookupByLibrary.simpleMessage('CANCEL'),
        "acceptButton": MessageLookupByLibrary.simpleMessage('ACCEPT'),
        "discardButton": MessageLookupByLibrary.simpleMessage('DISCARD'),
        "fixErrorsBeforeSubmittingPrompt": MessageLookupByLibrary.simpleMessage(
            'Please fix the errors in red before submitting.'),
        "newProductTitle": MessageLookupByLibrary.simpleMessage('New Product'),
        "saveButton": MessageLookupByLibrary.simpleMessage('SAVE'),
        "newProductName":
            MessageLookupByLibrary.simpleMessage("Product Name *"),
        "newProductNameHint":
            MessageLookupByLibrary.simpleMessage("How is this product called?"),
        "newProductBrandName":
            MessageLookupByLibrary.simpleMessage("Brand Name *"),
        "newProductBrandNameHint": MessageLookupByLibrary.simpleMessage(
            "Which company sells this product?"),
        "newProductWeight":
            MessageLookupByLibrary.simpleMessage("Amount with Unit"),
        "newProductWeightHint":
            MessageLookupByLibrary.simpleMessage("Example: 1.5l or 100g"),
        "newProductAddToList":
            MessageLookupByLibrary.simpleMessage("Add to current list"),
        "newProductAddedToList":
            MessageLookupByLibrary.simpleMessage(" was added to list "),
        "newProductStarExplanation":
            MessageLookupByLibrary.simpleMessage('* indicates required field'),
        "fieldRequiredError":
            MessageLookupByLibrary.simpleMessage("This field is required!"),
        "newProductNameToShort": MessageLookupByLibrary.simpleMessage(
            "This name seems to be to short"),
        "addedProduct":
            MessageLookupByLibrary.simpleMessage(' added'), //'Added "\$name"'
        "productWasAlreadyInList": MessageLookupByLibrary.simpleMessage(
            ' was already in list. The amount was increased by 1'), //"\$name" was
        "searchProductHint":
            MessageLookupByLibrary.simpleMessage("Search Product"),
        "noMoreProductsMessage":
            MessageLookupByLibrary.simpleMessage("No more products found!}"),
        "codeText": MessageLookupByLibrary.simpleMessage("Code: "),
        "removed": MessageLookupByLibrary.simpleMessage("removed"),
        "changePrimaryColor":
            MessageLookupByLibrary.simpleMessage("Primary Color"),
        "changeAccentColor":
            MessageLookupByLibrary.simpleMessage("Accent Color"),
        "changeDarkTheme": MessageLookupByLibrary.simpleMessage("Dark Theme"),
        "changeAccentTextColor":
            MessageLookupByLibrary.simpleMessage("Bright Icons"),
        "autoSync": MessageLookupByLibrary.simpleMessage("Auto-Sync"),
        "changePasswordButton":
            MessageLookupByLibrary.simpleMessage("CHANGE PASSWORD"),
        "currentPassword":
            MessageLookupByLibrary.simpleMessage("Current password"),
        "currentPasswordHint": MessageLookupByLibrary.simpleMessage(
            "Current password that should be changed"),
        "newPassword": MessageLookupByLibrary.simpleMessage("New password"),
        "newPasswordHint": MessageLookupByLibrary.simpleMessage(
            "The new password you have chosen"),
        "repeatNewPassword":
            MessageLookupByLibrary.simpleMessage("Repeat new password"),
        "repeatNewPasswordHint": MessageLookupByLibrary.simpleMessage(
            "Repeat the new password you have chosen"),
        "changePasswordPD":
            MessageLookupByLibrary.simpleMessage("Change Password"),
        "successful": MessageLookupByLibrary.simpleMessage("Successful"),
        "passwordSet":
            MessageLookupByLibrary.simpleMessage("Your password has been set"),
        "tokenExpired": MessageLookupByLibrary.simpleMessage("Token expired"),
        "tokenExpiredExplanation": MessageLookupByLibrary.simpleMessage(
            "Your token has expired. Login is required. If this happends multiple times per month, please contact us."),
        "noListLoaded": MessageLookupByLibrary.simpleMessage("No List Loaded"),
        "renameListItem":
            MessageLookupByLibrary.simpleMessage("Rename Product"),
        "renameListItemHint":
            MessageLookupByLibrary.simpleMessage("The new name of the product"),
        "renameListItemLabel":
            MessageLookupByLibrary.simpleMessage("new product name"),
        "discardNewTheme":
            MessageLookupByLibrary.simpleMessage('Discard new theme?'),
        "forgotPassword":
            MessageLookupByLibrary.simpleMessage('Forgot password?'),
        "bePatient": MessageLookupByLibrary.simpleMessage(
            'Please be patient, the server is processing your request already'),
        "logout": MessageLookupByLibrary.simpleMessage('Logout'),
        "deleteListTitle": MessageLookupByLibrary.simpleMessage('Delete List '),
        "deleteListText": MessageLookupByLibrary.simpleMessage(
            'Do you really want to delete the list? This CAN\'T be undone!'),
        "exportAsPdf": MessageLookupByLibrary.simpleMessage('Export as PDF'),
        "boughtProducts":
            MessageLookupByLibrary.simpleMessage('Bought Products'),
        "nothingBoughtYet":
            MessageLookupByLibrary.simpleMessage('Nothing bought yet'),
        "reorderItems": MessageLookupByLibrary.simpleMessage('Reorder'),
        "refresh": MessageLookupByLibrary.simpleMessage('Refresh'),
        "okayButton": MessageLookupByLibrary.simpleMessage('OKAY'),
        "requestPasswordResetButton":
            MessageLookupByLibrary.simpleMessage("REQUEST PASSWORD RESET"),
        "requestPasswordResetTitle":
            MessageLookupByLibrary.simpleMessage("Password Reset"),
        "requestPasswordResetSuccess": MessageLookupByLibrary.simpleMessage(
            'If the email exists, the password request was successfully requested. Further instructions can be found in the email, that was send to the address.'),
        "settings": MessageLookupByLibrary.simpleMessage('Settings'),
        "useMaterial3": MessageLookupByLibrary.simpleMessage(
            'Use Material Design 3 (Colors based on Android Version)'),
        "elevateAppBar":
            MessageLookupByLibrary.simpleMessage('Colorize Title Background'),
      };
}
