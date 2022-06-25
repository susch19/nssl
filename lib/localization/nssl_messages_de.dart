import 'package:intl/message_lookup_by_library.dart';

final messages = MessageLookup();

class MessageLookup extends MessageLookupByLibrary {
  get localeName => 'de';

  final Map<String, dynamic> messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => {
        "options": MessageLookupByLibrary.simpleMessage("Optionen"),
        "changeTheme": MessageLookupByLibrary.simpleMessage("Design ändern"),
        "scanPB": MessageLookupByLibrary.simpleMessage("SCANNEN"),
        "addPB": MessageLookupByLibrary.simpleMessage("ADD"), //TODO find good german word
        "searchPB": MessageLookupByLibrary.simpleMessage("SUCHEN"),
        "deleteCrossedOutPB": MessageLookupByLibrary.simpleMessage("Lösche Markierte"),
        "addListPB": MessageLookupByLibrary.simpleMessage("LISTE HINZUFÜGEN"),
        "contributors": MessageLookupByLibrary.simpleMessage("Teilnehmer"),
        "rename": MessageLookupByLibrary.simpleMessage("Umbenennen"),
        "remove": MessageLookupByLibrary.simpleMessage("Entfernen"),
        "addProduct": MessageLookupByLibrary.simpleMessage("Artikel hinzufügen"),
        "addProductWithoutSearch": MessageLookupByLibrary.simpleMessage("Name des Artikels"),
        "productName": MessageLookupByLibrary.simpleMessage("Artikelname"),
        "messageDeleteAllCrossedOut":
            MessageLookupByLibrary.simpleMessage("Alle durchgestrichenen Artikel wurden gelöscht"),
        "undo": MessageLookupByLibrary.simpleMessage("RÜCKG."),
        "removedShoppingListMessage": MessageLookupByLibrary.simpleMessage(" entfernt "), //\${User.shoppingLists}
        "noListsInDrawerMessage": MessageLookupByLibrary.simpleMessage(" Hier werden deine Listen angezeigt"),
        "notLoggedInYet": MessageLookupByLibrary.simpleMessage("Noch nicht eingeloggt"),
        "newNameOfListHint": MessageLookupByLibrary.simpleMessage("Neuer Listenname"),
        "listName": MessageLookupByLibrary.simpleMessage("Listenname"),
        "renameListTitle": MessageLookupByLibrary.simpleMessage("Liste umbenennen"),
        "renameListHint": MessageLookupByLibrary.simpleMessage("Der neue Name der Liste"),
        "addNewListTitle": MessageLookupByLibrary.simpleMessage("Füge eine neue Liste hinzu"),
        "recipeName": MessageLookupByLibrary.simpleMessage("Rezept"),
        "recipeNameHint": MessageLookupByLibrary.simpleMessage("Rezept ID oder URL"),
        "addNewRecipeTitle": MessageLookupByLibrary.simpleMessage("Füge eine neues Rezept hinzu"),
        "chooseAddListDialog": MessageLookupByLibrary.simpleMessage("Einkaufen"),
        "chooseAddRecipeDialog": MessageLookupByLibrary.simpleMessage("Chefkoch"),
        "youHaveActionItemMessage": MessageLookupByLibrary.simpleMessage('Du hast '), //\$action \$item
        "archived": MessageLookupByLibrary.simpleMessage('archiviert'),
        "deleted": MessageLookupByLibrary.simpleMessage('gelöscht'),
        "actionsForMessage": MessageLookupByLibrary.simpleMessage("archiviert" "gelöscht"),
        "youHaveActionNameMessage": MessageLookupByLibrary.simpleMessage("Du hast "), //\${s.name} \$action
        "demoteMenu": MessageLookupByLibrary.simpleMessage("Degradieren"),
        "promoteMenu": MessageLookupByLibrary.simpleMessage("Befördern"),
        "contributorUser": MessageLookupByLibrary.simpleMessage(" - User"),
        "contributorAdmin": MessageLookupByLibrary.simpleMessage(" - Admin"),
        "genericErrorMessageSnackbar":
            MessageLookupByLibrary.simpleMessage("Etwas Unerwartetes ist passiert!\n "), //\${z.error}
        "nameOfNewContributorHint": MessageLookupByLibrary.simpleMessage("Name des neuen Teilnehmers"),
        "wasRemovedSuccessfullyMessage": MessageLookupByLibrary.simpleMessage(" wurde erfolgreich gelöscht"),
        "loginSuccessfullMessage": MessageLookupByLibrary.simpleMessage("Login erfolgreich, die Listen werden geladen"),
        "nameEmailRequiredError": MessageLookupByLibrary.simpleMessage("Name oder EMail wird benötigt."),
        "usernameToShortError":
            MessageLookupByLibrary.simpleMessage("Der Benutzername muss aus mindestens 4 Zeichen bestehen"),
        "emailRequiredError": MessageLookupByLibrary.simpleMessage("EMail ist erforderlich"),
        "emailIncorrectFormatError":
            MessageLookupByLibrary.simpleMessage("Die EMail-Adresse scheint ein falsches Format zu haben"),
        "chooseAPassword": MessageLookupByLibrary.simpleMessage("Bitte ein Passwort eingeben"),
        "login": MessageLookupByLibrary.simpleMessage("Login"),
        "usernameOrEmailForLoginHint":
            MessageLookupByLibrary.simpleMessage("Benutzername oder EMail kann für's einloggen genutzt werden"),
        "usernameOrEmailTitle": MessageLookupByLibrary.simpleMessage("Benutzername oder EMail"),
        "emailTitle": MessageLookupByLibrary.simpleMessage('EMail'),
        "choosenPasswordHint": MessageLookupByLibrary.simpleMessage("Dein gewähltes Passwort"),
        "password": MessageLookupByLibrary.simpleMessage("Passwort"),
        "loginButton": MessageLookupByLibrary.simpleMessage("LOGIN"),
        "registerTextOnLogin":
            MessageLookupByLibrary.simpleMessage("Du hast noch keinen Account? Erstelle jetzt einen."),
        "usernameEmptyError": MessageLookupByLibrary.simpleMessage("Benutzername muss ausgefüllt sein"),
        "passwordEmptyError": MessageLookupByLibrary.simpleMessage("Passwort muss ausgefüllt sein"),
        "passwordTooShortError": MessageLookupByLibrary.simpleMessage("Passwort muss mindestens 6 Zeichen lang sein"),
        "passwordMissingCharactersError": MessageLookupByLibrary.simpleMessage(
            "Passwort muss mindestens ein spezielles Zeichen (Kann jedes Symbol/Emoji sein) und Buchstabe oder Zahl enthalten"),

        "emailEmptyError": MessageLookupByLibrary.simpleMessage("EMail muss ausgefüllt sein"),
        "reenterPasswordError":
            MessageLookupByLibrary.simpleMessage("Die Passwörter stimmen nicht überein oder sind leer"),
        "unknownUsernameError": MessageLookupByLibrary.simpleMessage("Es stimmt etwas mit deinem Benutzername nicht"),
        "unknownEmailError": MessageLookupByLibrary.simpleMessage("Es stimmt etwas mit deiner EMail nicht"),
        "unknownPasswordError": MessageLookupByLibrary.simpleMessage("Es stimmt etwas mit deinem Passwort nicht"),
        "unknownReenterPasswordError":
            MessageLookupByLibrary.simpleMessage("Es stimmt etwas mit dem wiederholten Passwort nicht"),
        "registrationSuccessfulMessage": MessageLookupByLibrary.simpleMessage("Registrierung erfolgreich"),
        "registrationTitle": MessageLookupByLibrary.simpleMessage("Registrierung"),
        "nameEmptyError": MessageLookupByLibrary.simpleMessage("Name ist erforderlich"),
        "chooseAPasswordPrompt": MessageLookupByLibrary.simpleMessage("Bitte gib ein Passwort ein"),
        "reenterPasswordPrompt": MessageLookupByLibrary.simpleMessage("Bitte gib dein Passwort erneut ein"),
        "passwordsDontMatchError": MessageLookupByLibrary.simpleMessage("Die Passwörter stimmen nicht überein"),
        "usernameRegisterHint":
            MessageLookupByLibrary.simpleMessage("Kann zum einloggen und zum gefunden werden genutzt werden"),
        "username": MessageLookupByLibrary.simpleMessage("Benutzername"),
        "emailRegisterHint":
            MessageLookupByLibrary.simpleMessage("Kann zum einloggen und zum gefunden werden genutzt werden"),
        "passwordRegisterHint": MessageLookupByLibrary.simpleMessage("Das Passwort schützt deinen Account"),
        "retypePasswordHint":
            MessageLookupByLibrary.simpleMessage("Bitte wiederhole dein Passwort um Fehler zu vermeiden"),
        "retypePasswordTitle": MessageLookupByLibrary.simpleMessage("Passwortwiederholung"),
        "registerButton": MessageLookupByLibrary.simpleMessage("REGISTRIEREN"),
        "discardNewProduct": MessageLookupByLibrary.simpleMessage("Änderungen verwerfen?"),
        "cancelButton": MessageLookupByLibrary.simpleMessage("ABBRECHEN"),
        "acceptButton": MessageLookupByLibrary.simpleMessage('ANNEHMEN'),
        "discardButton": MessageLookupByLibrary.simpleMessage("VERWERFEN"),
        "fixErrorsBeforeSubmittingPrompt":
            MessageLookupByLibrary.simpleMessage("Bitte behebe die Fehler, gekennzeichnet in Rot"),
        "newProductTitle": MessageLookupByLibrary.simpleMessage("Neues Produkt"),
        "saveButton": MessageLookupByLibrary.simpleMessage("SPEICHERN"),
        "newProductName": MessageLookupByLibrary.simpleMessage("Produktname *"),
        "newProductNameHint": MessageLookupByLibrary.simpleMessage("Was steht auf der Verpackung?"),
        "newProductBrandName": MessageLookupByLibrary.simpleMessage("Markenname"),
        "newProductBrandNameHint": MessageLookupByLibrary.simpleMessage("Von welcher Marke ist das Produkt?"),
        "newProductWeight": MessageLookupByLibrary.simpleMessage("Menge mit Einheit"),
        "newProductWeightHint": MessageLookupByLibrary.simpleMessage("Zum Beispiel: 1,5l oder 100g"),
        "newProductAddToList": MessageLookupByLibrary.simpleMessage("Füge es der aktuellen Liste hinzu"),
        "newProductAddedToList": MessageLookupByLibrary.simpleMessage(" wurde hinzugefügt zur Liste "),
        "newProductStarExplanation": MessageLookupByLibrary.simpleMessage("* kennzeichnet die benötigten Felder"),
        "fieldRequiredError": MessageLookupByLibrary.simpleMessage("Dieses Feld wird benötigt!"),
        "newProductNameToShort": MessageLookupByLibrary.simpleMessage("Dieser Name scheint zu kurz zu sein"),
        "addedProduct": MessageLookupByLibrary.simpleMessage(' hinzugefügt'), //"\$name"
        "productWasAlreadyInList": MessageLookupByLibrary.simpleMessage(
            ' ist bereits in der Liste. Die Menge wurde um 1 erhöht'), //"\$name" ist
        "searchProductHint": MessageLookupByLibrary.simpleMessage("Produktsuche"),
        "noMoreProductsMessage":
            MessageLookupByLibrary.simpleMessage("Es konnten keine weiteren Produkte mit dem Namen gefunden werden"),
        "codeText": MessageLookupByLibrary.simpleMessage("Code: "),
        "removed": MessageLookupByLibrary.simpleMessage("entfernt"),
        "changePrimaryColor": MessageLookupByLibrary.simpleMessage("Hauptfarbe"),
        "changeAccentColor": MessageLookupByLibrary.simpleMessage("Akzentfarbe"),
        "changeDarkTheme": MessageLookupByLibrary.simpleMessage("Dunkles Design"),
        "changeAccentTextColor": MessageLookupByLibrary.simpleMessage("Helle Icons"),
        "autoSync": MessageLookupByLibrary.simpleMessage("Auto-Sync"),
        "changePasswordButton": MessageLookupByLibrary.simpleMessage("ÄNDERE PASSWORT"),
        "currentPassword": MessageLookupByLibrary.simpleMessage("Aktuelles Passwort"),
        "currentPasswordHint": MessageLookupByLibrary.simpleMessage("Das aktuelle Passwort, dass geändert werden soll"),
        "newPassword": MessageLookupByLibrary.simpleMessage("Neues Passwort"),
        "newPasswordHint": MessageLookupByLibrary.simpleMessage("Das neu gewählte Passwort"),
        "repeatNewPassword": MessageLookupByLibrary.simpleMessage("Neues Passwort wiederholen"),
        "repeatNewPasswordHint": MessageLookupByLibrary.simpleMessage("Wiederholung des neu gewählten Passworts"),
        "changePasswordPD": MessageLookupByLibrary.simpleMessage("Ändere Passwort"),
        "successful": MessageLookupByLibrary.simpleMessage("Erfolgreich"),
        "passwordSet": MessageLookupByLibrary.simpleMessage("Dein Passwort wurde erfolgreich geändert"),
        "tokenExpired": MessageLookupByLibrary.simpleMessage("Token abgelaufen"),
        "tokenExpiredExplanation": MessageLookupByLibrary.simpleMessage(
            "Der Token ist abgelaufen. Deshalb wird ein erneuter Login benötigt. Es handelt sich hierbei erst um ein Fehler, falls diese Meldung mehrmals im Monat aufkommt."),
        "noListLoaded": MessageLookupByLibrary.simpleMessage("Keine Liste geladen"),
        "renameListItem": MessageLookupByLibrary.simpleMessage("Produkt umbenennen"),
        "renameListItemHint": MessageLookupByLibrary.simpleMessage("Der neue Name des Produktes"),
        "renameListItemLabel": MessageLookupByLibrary.simpleMessage("Neuer Prdouktname"),
        "discardNewTheme": MessageLookupByLibrary.simpleMessage("Änderungen verwerfen?"),
        "forgotPassword": MessageLookupByLibrary.simpleMessage("Passwort vergessen?"),
        "bePatient": MessageLookupByLibrary.simpleMessage('Der Server bearbeitet diese Anfrage bereits'),
        "logout": MessageLookupByLibrary.simpleMessage('Ausloggen'),
        "deleteListTitle": MessageLookupByLibrary.simpleMessage('Lösche Liste '),
        "deleteListText": MessageLookupByLibrary.simpleMessage(
            'Soll diese Liste wirklich gelöscht werden? Das kann NICHT rückgängig gemacht werden!'),
        "exportAsPdf": MessageLookupByLibrary.simpleMessage('Als PDF exportieren'),
        "boughtProducts": MessageLookupByLibrary.simpleMessage('Eingekauft'),
        "nothingBoughtYet": MessageLookupByLibrary.simpleMessage('Noch nichts eingekauft'),
        "reorderItems": MessageLookupByLibrary.simpleMessage('Reihenfolge'),
        "refresh": MessageLookupByLibrary.simpleMessage('Aktualisieren'),
        "okayButton": MessageLookupByLibrary.simpleMessage('OKAY'),
        "requestPasswordResetButton": MessageLookupByLibrary.simpleMessage("PASSWORT ZURÜCKSETZUNG BEANTRAGEN"),
        "requestPasswordResetTitle": MessageLookupByLibrary.simpleMessage("Passwort zurücksetzen"),
        "requestPasswordResetSuccess": MessageLookupByLibrary.simpleMessage(
            'Die Passwort zurücksetzen Email wurde erfolgreich an die Adresse gesendet, sollte diese existieren. Weitere Schritte für das abschließen des Resets sind in der Email enthalten.'),
        "settings": MessageLookupByLibrary.simpleMessage('Einstellungen'),
        "about": MessageLookupByLibrary.simpleMessage('Über'),
        "codeOnGithub": MessageLookupByLibrary.simpleMessage('Schau doch mal in den Code auf GitHub rein'),
        "playstoreEntry": MessageLookupByLibrary.simpleMessage('Play Store Eintrag'),
        "iconSource": MessageLookupByLibrary.simpleMessage('Wer hat dieses schicke Icon gemacht? Finde es heraus!'),
        "scanditCredit":
            MessageLookupByLibrary.simpleMessage('hat diesen super Scanner in der App zur Verfügung gestellt'),
        "aboutText": MessageLookupByLibrary.simpleMessage(
            'In jahrelanger Handarbeit geschmiedet mit dem einzigen Ziel, die Einkaufsplanung mit anderen zu vereinfachen und dabei seine Lieblingsprodukte blitzschnell per Kamera zu erfassen.'),
        "freeText": MessageLookupByLibrary.simpleMessage('Kostenlos, Werbefrei, für immer!'),
        "questionsErrors": MessageLookupByLibrary.simpleMessage(
            'Bei Fragen, Anregungen, Fehlern oder sonstigen Belangen kann jederzeit auf GitHub vorbeigeschaut werden, um ein Issue zu eröffnen.'),
      };
}
