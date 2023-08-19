import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

void main() {
  runApp(HotReload());
}

class HotReload extends StatelessWidget {
  const HotReload({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Widgetbook(
      categories: [
        WidgetbookCategory(
          name: 'widgets',
          widgets: [
            WidgetbookWidget(
              name: 'Button',
              useCases: [
                WidgetbookUseCase(
                  name: 'elevated',
                  builder: (context) => ElevatedButton(
                    onPressed: () {},
                    child: const Text('Widgetbook'),
                  ),
                ),
              ],
            ),
          ],
        )
      ],
      appInfo: AppInfo(name: 'Example'),
    );
  }
}
