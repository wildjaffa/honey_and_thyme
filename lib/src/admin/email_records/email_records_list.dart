import 'package:flutter/material.dart';
import 'package:honey_and_thyme/src/admin/admin.dart';
import 'package:honey_and_thyme/src/models/email_record.dart';
import 'package:honey_and_thyme/src/models/enums/message_status.dart';
import 'package:honey_and_thyme/src/services/email_records_service.dart';
import 'package:honey_and_thyme/src/widgets/back_or_add_buttons.dart';
import 'package:intl/intl.dart';

import '../../models/enums/screens.dart';

import '../../widgets/app_scaffold.dart';
import '../authenticate.dart';
import 'package:web/web.dart' as html;

class EmailRecordsList extends StatefulWidget {
  const EmailRecordsList({super.key});

  static const String route = '/email-records';

  @override
  State<EmailRecordsList> createState() => _EmailRecordsListState();
}

class _EmailRecordsListState extends State<EmailRecordsList> {
  int page = 0;
  int pageSize = 10;

  late Future<PaginatedEmailRecords?> emailRecords;

  @override
  void initState() {
    super.initState();
    emailRecords = EmailRecordsService.fetchRecords(page, pageSize, null, null);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentScreen: ScreensEnum.admin,
      child: Authenticate(
        child: Center(
          child: LayoutBuilder(builder: (context, constraints) {
            final width = constraints.maxWidth;
            return SizedBox(
              width: width * 0.8,
              child: FutureBuilder(
                future: emailRecords,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: snapshot.data!.results!.length + 2,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return BackOrAddButtons(
                          backRoute: AdminView.route,
                        );
                      }
                      if (index == snapshot.data!.results!.length + 1) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: page == 0
                                  ? null
                                  : () {
                                      setState(() {
                                        page--;
                                        emailRecords =
                                            EmailRecordsService.fetchRecords(
                                                page, pageSize, null, null);
                                      });
                                    },
                            ),
                            Text(
                                'Page ${page + 1} of ${snapshot.data!.pageCount}'),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward),
                              onPressed: page + 1 == snapshot.data!.pageCount
                                  ? null
                                  : () {
                                      setState(() {
                                        page++;
                                        emailRecords =
                                            EmailRecordsService.fetchRecords(
                                                page, pageSize, null, null);
                                      });
                                    },
                            ),
                          ],
                        );
                      }
                      final email = snapshot.data!.results![index - 1];
                      return ListTile(
                        title: Text(email.subject!),
                        subtitle: Text(email.email!),
                        leading: IconButton(
                          icon: Icon(
                            Icons.send,
                            color: email.status == MessageStatus.sent
                                ? Colors.green
                                : Colors.red,
                          ),
                          onPressed: () {
                            EmailRecordsService.reSendEmail(
                                email.emailRecordId!);
                          },
                        ),
                        trailing: Text(
                          DateFormat.yMd()
                              .add_jm()
                              .format(email.dateSent!.toLocal()),
                          style: const TextStyle(fontSize: 18),
                        ),
                        onLongPress: () {
                          final newWindow =
                              html.window.open("about:blank", "", "_blank");
                          newWindow!.window.document.write(email.htmlMessage!);
                        },
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const Divider();
                    },
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }
}
