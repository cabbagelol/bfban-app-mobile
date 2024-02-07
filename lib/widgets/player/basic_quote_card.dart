import 'package:bfban/component/_html/html.dart';
import "package:flutter/material.dart";

import '../../utils/index.dart';

class QuoteCard extends StatefulWidget {
  final Map? data;

  const QuoteCard({
    Key? key,
    this.data,
  }) : super(key: key);

  @override
  State<QuoteCard> createState() => _QuoteCardState();
}

class _QuoteCardState extends State<QuoteCard> {
  Map? quote;

  @override
  void initState() {
    if (widget.data!.containsKey("quote")) quote = widget.data!["quote"];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (quote == null) {
      return Container();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerTheme.color!, width: 1),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  quote!["username"],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(Date().getTimestampTransferCharacter(quote!['createTime'])["Y_D_M"])
            ],
          ),
          const SizedBox(height: 5),
          HtmlCore(data: quote!["content"]),
        ],
      ),
    );
  }
}
