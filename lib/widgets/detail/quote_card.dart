import "package:flutter/material.dart";

import '../../component/_html/htmlWidget.dart';
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
    quote = widget.data!["quote"];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (quote == null) {
      return Container();
    }

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Theme.of(context).primaryColorDark.withOpacity(.2),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  Date().getTimestampTransferCharacter(quote!['createTime'])["Y_D_M"],
                )
              ],
            ),
            HtmlWidget(content: quote!["content"]),
          ],
        ),
      ),
    );
  }
}
