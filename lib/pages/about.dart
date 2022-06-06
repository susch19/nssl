import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nssl/localization/nssl_strings.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(NSSLStrings.of(context).about()),
      ),
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    var iconColor = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark ? Colors.white : Colors.black;
    return ListView(
      children: [
        Container(
          margin: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Center(
                child: SvgPicture.asset(
                  "assets/vectors/nssl_icon.svg",
                  width: 200,
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  top: 8.0,
                ),
                child: Center(
                  child: Text(
                    "Non Sucking Shopping List",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(),
        ListTile(
          title: Text(
            NSSLStrings.of(context).freeText(),
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        ListTile(
          title: Text(
            NSSLStrings.of(context).aboutText(),
            textAlign: TextAlign.center,
          ),
          // "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."),
        ),
        ListTile(
          title: Text(
            NSSLStrings.of(context).questionsErrors(),
            textAlign: TextAlign.center,
          ),
        ),
        Divider(),
        ListTile(
          title: Text(
            "Entwickelt von susch19 (Sascha Hering)",
          ),
        ),
        ListTile(
          title: Text("Version 0.27"),
        ),
        Divider(),
        ListTile(
          leading: SvgPicture.asset(
            "assets/vectors/github.svg",
            color: iconColor,
            width: 32,
          ),
          title: Text(NSSLStrings.of(context).codeOnGithub()),
          onTap: () {
            var urlString = Uri.parse("https://github.com/susch19/nssl");
            canLaunchUrl(urlString).then((value) {
              if (value) launchUrl(urlString);
            });
          },
        ),
        Divider(),
        ListTile(
          leading: SvgPicture.asset("assets/vectors/nssl_icon.svg", alignment: Alignment.center, width: 32),
          title: Text(NSSLStrings.of(context).iconSource()),
          onTap: () {
            var urlString = Uri.parse("https://www.flaticon.com/free-icon/check-list_306470");
            canLaunchUrl(urlString).then((value) {
              if (value) launchUrl(urlString);
            });
          },
        ),
        Divider(),
        ListTile(
          leading: SvgPicture.asset("assets/vectors/google_play.svg", alignment: Alignment.center, width: 32),
          title: Text(NSSLStrings.of(context).playstoreEntry()),
          onTap: () {
            var urlString = Uri.parse("https://play.google.com/store/apps/details?id=de.susch19.nssl");
            canLaunchUrl(urlString).then((value) {
              if (value) launchUrl(urlString);
            });
          },
        ),
        Divider(),
        ListTile(
          leading: Image.asset("assets/images/scandit.png", alignment: Alignment.center, width: 128, color: iconColor),
          title: Text(NSSLStrings.of(context).scanditCredit()),
          onTap: () {
            var urlString = Uri.parse("https://scandit.com");
            canLaunchUrl(urlString).then((value) {
              if (value) launchUrl(urlString);
            });
          },
        ),
      ],
    );
  }
}
