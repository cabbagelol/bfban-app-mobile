import 'package:bfban/component/_empty/index.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_license_page/flutter_custom_license_page.dart';
import 'package:flutter_elui_plugin/_load/index.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

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
      body: CustomLicensePage((context, AsyncSnapshot<LicenseData> licenseDataFuture) {
        switch (licenseDataFuture.connectionState) {
          case ConnectionState.done:
            LicenseData? licenseData = licenseDataFuture.data;

            return ListView(
              children: [
                ...licenseDataFuture.data!.packages.map((currentPackage) {
                  return ListTile(
                    isThreeLine: true,
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
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(25),
                                    child: Text(
                                      packageLicenses
                                          .map(
                                            (e) => e.paragraphs.map((e) => e.text).toList().reduce((value, element) => "$value\n$element"),
                                          )
                                          .reduce((value, element) => "$value\n\n$element"),
                                    ),
                                  )
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
            return ELuiLoadComponent(
              type: "line",
              color: Theme.of(context).appBarTheme.backgroundColor!,
              size: 25,
              lineWidth: 2,
            );
          default:
            return const EmptyWidget();
        }
      }),
    );
  }
}
