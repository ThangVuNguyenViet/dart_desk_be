import 'package:flutter_test/flutter_test.dart';

import 'package:dart_desk_manage/main.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const ManageApp());
    await tester.pumpAndSettle();
  });
}
