import 'package:bfban/component/_empty/index.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_license_page/flutter_custom_license_page.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import '../../component/_html/html.dart';
import '../../component/_html/htmlWidget.dart';

class LicensePage extends StatefulWidget {
  const LicensePage({Key? key}) : super(key: key);

  @override
  State<LicensePage> createState() => _LicensePageState();
}

class _LicensePageState extends State<LicensePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "app.setting.support.licenseTitle")),
      ),
      body: CustomLicensePage(
        (context, AsyncSnapshot<LicenseData> licenseDataFuture) {
          switch (licenseDataFuture.connectionState) {
            case ConnectionState.done:
              LicenseData? licenseData = licenseDataFuture.data;

              return ListView(
                children: [
                  ...licenseDataFuture.data!.packages.map((currentPackage) {
                    return ListTile(
                      isThreeLine: false,
                      title: Text(currentPackage.toString()),
                      subtitle: Text(
                        "${licenseData!.packageLicenseBindings[currentPackage]!.length} Licenses",
                        style: TextStyle(
                          color: Theme.of(context).textTheme.displayMedium!.color,
                        ),
                      ),
                      trailing: const Icon(Icons.keyboard_arrow_right),
                      onTap: () {
                        List<LicenseEntry> packageLicenses = licenseData.packageLicenseBindings[currentPackage]!.map((binding) => licenseData.licenses[binding]).toList();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return Scaffold(
                                appBar: AppBar(
                                  title: Text(currentPackage),
                                ),
                                body: ListView(
                                  padding: const EdgeInsets.all(10),
                                  children: [
                                    HtmlCore(
                                      data: packageLicenses.map((e) => e.paragraphs.map((e) => e.text).toList().reduce((value, element) => "$value<br/><br/>$element")).reduce((value, element) => "$value<br/><br/>$element"),
                                      style: CardUtil().styleHtml(context),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  })
                ],
              );

            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            default:
              return const EmptyWidget();
          }
        },
      ),
    );
  }
}
