import 'package:flutter/material.dart';
import 'package:honey_and_thyme/src/admin/admin.dart';
import 'package:honey_and_thyme/src/models/email_record.dart';
import 'package:honey_and_thyme/src/models/enums/message_status.dart';
import 'package:honey_and_thyme/src/services/email_records_service.dart';
import 'package:honey_and_thyme/src/widgets/back_or_add_buttons.dart';
import 'package:honey_and_thyme/src/widgets/pagination_controls.dart';
import 'package:honey_and_thyme/src/widgets/pagination_state.dart';
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
  final PaginationState _paginationState = PaginationState();
  late Future<PaginatedEmailRecords?> emailRecords;

  @override
  void initState() {
    super.initState();
    _loadEmailRecords();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _loadEmailRecords() {
    emailRecords = EmailRecordsService.fetchRecords(
        _paginationState.currentPage, _paginationState.pageSize, null, null);
  }

  void _nextPage() {
    _paginationState.nextPage();
    setState(() {
      _loadEmailRecords();
    });
  }

  void _previousPage() {
    _paginationState.previousPage();
    setState(() {
      _loadEmailRecords();
    });
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
                        return PaginationControls(
                          currentPage: _paginationState.currentPage,
                          totalPages: snapshot.data!.pageCount ?? 1,
                          onPreviousPage: _paginationState.currentPage == 0
                              ? null
                              : () {
                                  _previousPage();
                                },
                          onNextPage: _paginationState.currentPage + 1 ==
                                  (snapshot.data!.pageCount ?? 1)
                              ? null
                              : () {
                                  _nextPage();
                                },
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
