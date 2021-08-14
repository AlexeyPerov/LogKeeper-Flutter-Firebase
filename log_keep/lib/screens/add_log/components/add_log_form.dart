import 'package:clipboard/clipboard.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:log_keep/app/app.dart';
import 'package:log_keep/app/configs.dart';
import 'package:log_keep/app/theme/theme_constants.dart';
import 'package:log_keep/app/theme/themes.dart';
import 'package:log_keep/repositories/logs_repository.dart';
import 'package:log_keep/screens/home/home_screen.dart';
import 'package:uiblock/uiblock.dart';

class AddLogForm extends StatefulWidget {
  final AddLogFormParameters form;

  const AddLogForm({Key key, @required this.form}) : super(key: key);

  @override
  _AddLogFormState createState() => _AddLogFormState();
}

class _AddLogFormState extends State<AddLogForm> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _authorController;
  TextEditingController _titleController;
  TextEditingController _projectController;
  TextEditingController _fileController;
  String _contents;

  @override
  void initState() {
    super.initState();
    _authorController = TextEditingController();
    _titleController = TextEditingController();
    _fileController = TextEditingController();
    _projectController = TextEditingController(text: widget.form.project);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 10),
          child: Row(
            children: [
              SizedBox(
                  height: 40,
                  width: 40,
                  child: IconButton(
                      icon: Icon(Icons.arrow_back_ios, size: 25),
                      onPressed: () => HomeScreenNavigation.navigate(context)))
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
              child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 30.0),
                  child: TextFormField(
                    autocorrect: false,
                    controller: _projectController,
                    decoration: _textFieldStyle(helperText: 'Project name'),
                    validator: _validateNonEmpty,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 30.0),
                  child: TextFormField(
                    maxLines: 3,
                    autocorrect: false,
                    controller: _titleController,
                    decoration: _textFieldStyle(helperText: 'Title'),
                    validator: _validateNonEmpty,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 30.0),
                  child: TextFormField(
                    autocorrect: false,
                    controller: _authorController,
                    decoration: _textFieldStyle(helperText: 'Author'),
                    validator: _validateNonEmpty,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 30.0),
                  child: TextFormField(
                    autocorrect: false,
                    readOnly: true,
                    controller: _fileController,
                    decoration: _textFieldStyle(helperText: 'File to upload'),
                    validator: _validateNonEmpty,
                    onTap: () async {
                      FilePickerCross logFile =
                          await FilePickerCross.importFromStorage(
                              type: FileTypeCross.custom,
                              fileExtension: '.txt, .md, .log');

                      try {
                        _contents = logFile.toString();
                        setState(() {
                          _fileController.text = logFile.fileName;
                        });
                      } catch (e) {
                        logger.e(e);
                      }
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 30.0),
                  child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        height: 55.0,
                        width: 150.0,
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [commonBoxShadow()],
                        ),
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () => () {
                            if (_formKey.currentState.validate()) {
                              widget.form.logInputData.author =
                                  _authorController.text;
                              widget.form.logInputData.title =
                                  _titleController.text;
                              widget.form.logInputData.contents = _contents;
                              widget.form.logInputData.createdAt =
                                  DateTime.now();
                              widget.form.project = _projectController.text;

                              _addPressed(context);
                            }
                          },
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Submit".toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      )),
                )
              ],
            ),
          )),
        ),
      ],
    );
  }

  static String _validateNonEmpty(String value) {
    if (value.isEmpty) {
      return 'Field cannot be empty';
    }
    return null;
  }

  static InputDecoration _textFieldStyle({String helperText = ''}) {
    return InputDecoration(
      contentPadding: EdgeInsets.all(12),
      helperText: helperText,
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[500])),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300])),
    );
  }

  void _addPressed(BuildContext context) {
    UIBlock.block(context,
        loadingTextWidget: Text('Deleting...'),
        backgroundColor: Colors.blueGrey);

    RepositoryProvider.of<LogsRepository>(context)
        .addLog(widget.form.project, widget.form.logInputData)
        .then((value) => {
              if (!kIsWeb) {_copyLink(context, value)}
            })
        .whenComplete(() => {_additionCompleted(context)});
  }

  void _additionCompleted(BuildContext context) {
    UIBlock.unblock(context);
    HomeScreenNavigation.navigate(context);
  }

  void _copyLink(BuildContext context, String id) {
    FlutterClipboard.copy(serverUrlFormat() + id).then((result) {
      final snackBar =
          SnackBar(content: Text('Link to the new log copied to clipboard'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }
}

class AddLogFormParameters {
  final LogCreationArguments logInputData = new LogCreationArguments();
  String project;

  AddLogFormParameters({this.project});
}
