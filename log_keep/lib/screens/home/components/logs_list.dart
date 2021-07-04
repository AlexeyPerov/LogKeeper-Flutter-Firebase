import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:log_keep/app/app.dart';
import 'package:log_keep/app/theme/theme_constants.dart';
import 'package:log_keep/app/theme/themes.dart';
import 'package:log_keep/bloc/log_infos/log_infos.dart';
import 'package:log_keep/bloc/projects/projects.dart';
import 'package:log_keep/common/utilities/navigator_utilities.dart';
import 'package:log_keep/common/utilities/web_utilities.dart';
import 'package:log_keep/repositories/logs_repository.dart';
import 'package:log_keep/screens/details/details_screen.dart';
import 'package:log_keep/screens/details/services/log_deletion_service.dart';
import 'package:log_keep_shared/log_keep_shared.dart';
import 'package:log_keep/common/utilities/string_extensions.dart';
import 'package:proviso/proviso.dart';

class LogsList extends StatefulWidget {
  final List<ProjectInfo> projects;
  final String selectedProject;

  LogsList({Key key, @required this.projects, @required this.selectedProject})
      : super(key: key);

  @override
  _LogsListState createState() => _LogsListState();
}

class _LogsListState extends State<LogsList> {
  @override
  Widget build(BuildContext context) {
    var totalHeight = MediaQuery.of(context).size.height;
    var projectsListHeight = 200.0;

    return ListView(
      children: <Widget>[
        SizedBox(height: 20.0),
        Container(
          height: projectsListHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.projects.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return SizedBox(width: 20.0);
              }
              return _projectCard(index - 1, projectsListHeight, widget.projects[index - 1]);
            },
          ),
        ),
        Container(
          height: totalHeight - projectsListHeight - 20,
          child: BlocBuilder<LogInfosBloc, LogInfosState>(
            builder: (context, LogInfosState state) {
              var list = state.logs;

              list.sort((a, b) => b.createdAt.compareTo(a.createdAt));

              return ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: list.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == list.length) {
                    return SizedBox(height: 80);
                  }

                  var log = list[index];
                  return Container(
                      padding: EdgeInsets.only(top: 20),
                      child: _logCard(context, log));
                },
              );
            },
          ),
        )
      ],
    );
  }

  Widget _projectCard(int index, double height, ProjectInfo projectInfo) {
    var selected = widget.selectedProject == projectInfo.project;
    var projectNameStyle = TextStyle(
      color: selected ? Colors.white : Color(0xFFAFB4C6),
      fontSize: 28.0,
      fontWeight: FontWeight.bold,
    );

    var logsCountStyle = TextStyle(
      color: selected ? Colors.white : Colors.black,
      fontSize: 25.0,
      fontWeight: FontWeight.bold,
    );

    return GestureDetector(
      onTap: () {
        BlocProvider.of<ProjectsBloc>(context)
            .add(SelectProject(projectInfo.project));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
        height: height,
        width: 175.0,
        decoration: BoxDecoration(
          color: selected ? kPrimaryColor : Color(0xFFF5F7FB),
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [selected ? commonBoxShadow() : slightBoxShadow()],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                projectInfo.project,
                overflow: TextOverflow.fade,
                maxLines: 2,
                style: projectNameStyle,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20.0, bottom: 20.0),
              child: StreamBuilder(
                stream: projectInfo.logsCount,
                builder: (context, AsyncSnapshot<int> snapshot) {
                  String count = '';

                  if (snapshot.hasData) {
                    count = snapshot.data.toString();
                  }

                  return Text(
                    count,
                    style: logsCountStyle,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logCard(BuildContext context, LogInfoEntity logInfo) {
    var title = logInfo.title.splitWordsByLength(kIsWeb ? 64 : 32);
    var titleMainStyle = const TextStyle(
      color: Colors.black,
      fontSize: 18.0,
      decoration: TextDecoration.underline,
      fontWeight: FontWeight.w600,
    );
    var titleSecondaryStyle = const TextStyle(
      color: Colors.black,
      fontSize: 14.0,
      fontWeight: FontWeight.w300,
    );
    var dateStyle = const TextStyle(
      color: Color(0xFFAFB4C6),
      fontSize: 18.0,
      fontWeight: FontWeight.w500,
    );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30.0),
      padding: EdgeInsets.all(30.0),
      decoration: BoxDecoration(
          color: Color(0xFFF5F7FB),
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: [minorBoxShadow()]),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => NavigatorUtilities.pushWithNoTransition(
            context,
            (_, __, ___) => DetailsScreen(
                arguments: LogDetailsLoadArguments(logId: logInfo.id))),
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                title.item1,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: titleMainStyle,
              ),
            ),
            SizedBox(height: 10.0),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                title.item2,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: titleSecondaryStyle,
              ),
            ),
            SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  dateFormatter.format(logInfo.createdAt),
                  style: dateStyle,
                ),
                SizedBox(width: 10.0),
                Text(
                  timeFormatter.format(logInfo.createdAt),
                  style: dateStyle,
                ),
                SizedBox(width: 10.0),
                ConditionWidget(
                  condition: kIsWeb,
                  widget: Text(
                    logInfo.author,
                    maxLines: 1,
                    style: dateStyle,
                  ),
                ),
                Spacer(),
                ConditionWidget(
                  condition: kIsWeb,
                  widget: LogCardMiniButton(
                      icon: Icons.filter,
                      pressed: () => getIt<LogsRepository>()
                          .getLogById(logInfo.id)
                          .then((value) =>
                              WebUtilities.openStringContentInNewPage(
                                  value.data.contents))),
                ),
                ConditionWidget(
                  condition: kIsWeb,
                  widget: LogCardMiniButton(
                      icon: Icons.delete,
                      pressed: () => LogDeletionService.requestDeletion(
                          context, widget.selectedProject, logInfo)),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LogCardMiniButton extends StatelessWidget {
  final IconData icon;
  final Function pressed;

  const LogCardMiniButton({Key key, this.icon, this.pressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 10, top: 10),
      child: SizedBox(
        height: 30,
        width: 30,
        child: FlatButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(60),
          ),
          padding: EdgeInsets.zero,
          onPressed: pressed,
          child: Icon(icon, size: 25),
        ),
      ),
    );
  }
}
