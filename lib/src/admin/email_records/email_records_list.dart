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
  late PaginationState<PaginatedEmailRecords> _paginationState;

  @override
  void initState() {
    super.initState();
    _paginationState = PaginationState<PaginatedEmailRecords>(
      dataFetchCallback: _fetchEmailRecords,
    );
    _paginationState.loadInitialData();
  }

  @override
  void dispose() {
    _paginationState.dispose();
    super.dispose();
  }

  Future<PaginatedEmailRecords?> _fetchEmailRecords(
      int page, int pageSize) async {
    return await EmailRecordsService.fetchRecords(page, pageSize, null, null);
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
              child: ListenableBuilder(
                listenable: _paginationState,
                builder: (context, child) {
                  if (_paginationState.isLoading) {
                    return const CircularProgressIndicator();
                  }
                  if (_paginationState.error != null) {
                    return Text('Error: ${_paginationState.error}');
                  }
                  if (_paginationState.data == null) {
                    return const Text('No email records found');
                  }

                  final emailRecordsData = _paginationState.data!;

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.all(8),
                          itemCount: emailRecordsData.results!.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return BackOrAddButtons(
                                backRoute: AdminView.route,
                              );
                            }
                            final email = emailRecordsData.results![index - 1];
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
                                final newWindow = html.window
                                    .open("about:blank", "", "_blank");
                                newWindow!.window.document
                                    .write(email.htmlMessage!);
                              },
                            );
                          },
                          separatorBuilder: (context, index) {
                            return const Divider();
                          },
                        ),
                      ),
                      // Pagination controls
                      if (emailRecordsData.results?.isNotEmpty == true)
                        PaginationControls<PaginatedEmailRecords>(
                          paginationState: _paginationState,
                          onUpdate: (paginationState) {
                            _fetchEmailRecords(paginationState.pageIndex,
                                paginationState.pageSize);
                          },
                        ),
                    ],
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
