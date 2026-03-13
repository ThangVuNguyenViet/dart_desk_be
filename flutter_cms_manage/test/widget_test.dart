import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_cms_manage/main.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const ManageApp());
    await tester.pumpAndSettle();
  });
}
