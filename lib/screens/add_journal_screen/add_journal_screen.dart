import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_webapi_first_course/helpers/weekday.dart';
import 'package:flutter_webapi_first_course/services/journal_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../helpers/logout.dart';
import '../../models/journal.dart';
import '../commom/exception_dialog.dart';

class AddJournalScreen extends StatelessWidget {
  AddJournalScreen({Key? key, required this.journal, required this.isEditing})
      : super(key: key);
  final Journal journal;
  final bool isEditing;
  final TextEditingController _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _contentController.text = journal.content;
    return Scaffold(
      appBar: AppBar(
        title: Text(WeekDay(journal.createdAt).toString()),
        actions: [
          IconButton(
              onPressed: () {
                registerJournal(context);
              },
              icon: const Icon(Icons.check)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: _contentController,
          keyboardType: TextInputType.multiline,
          style: const TextStyle(fontSize: 24),
          expands: true,
          minLines: null,
          maxLines: null,
        ),
      ),
    );
  }

  registerJournal(BuildContext context) {
    SharedPreferences.getInstance().then(
      (prefs) {
        String? token = prefs.getString('accessToken');

        if (token != null) {
          String content = _contentController.text;
          JournalService service = JournalService();
          journal.content = content;

          if (isEditing) {
            service
                .edit(journal.id, journal, token: token)
                .then((value) => Navigator.pop(context, value))
                .catchError(
              (onError) {
                logout(context);
              },
              test: (onError) => onError is TokenNotValidException,
            ).catchError(
              (onError) {
                var error = onError as HttpException;
                showExceptionDialog(context, content: error.message);
              },
              test: (onError) => onError is HttpException,
            );
          } else {
            service
                .register(journal, token: token)
                .then((value) => Navigator.pop(context, value))
                .catchError(
              (onError) {
                logout(context);
              },
              test: (onError) => onError is TokenNotValidException,
            ).catchError(
              (onError) {
                var error = onError as HttpException;
                showExceptionDialog(context, content: error.message);
              },
              test: (onError) => onError is HttpException,
            );
          }
        }
      },
    );
  }
}
