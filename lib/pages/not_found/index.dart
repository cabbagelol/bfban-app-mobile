import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class NotFoundPage extends StatefulWidget {
  const NotFoundPage({Key? key}) : super(key: key);

  @override
  State<NotFoundPage> createState() => _NotFoundPageState();
}

class _NotFoundPageState extends State<NotFoundPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 0,
        centerTitle: true,
        title: const Text("Network unavailable"),
      ),
      body: const Center(
        child: Opacity(
          opacity: .2,
          child: Icon(Icons.restart_alt_rounded, size: 100),
        ),
      ),
    );
  }
}
