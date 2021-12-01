import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
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
import 'package:log_keep/screens/home/services/project_archiving_service.dart';
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
  final _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    var totalHeight = MediaQuery.of(context).size.height;
    var projectsListHeight = 160.0;

    return ListView(
      children: <Widget>[
        SizedBox(height: 20.0),
        Container(
          height: projectsListHeight,
          child: FadingEdgeScrollView.fromScrollView(
              child: ListView.builder(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            itemCount: widget.projects.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return SizedBox(width: 20.0);
              }
              return _projectCard(
                  index - 1, projectsListHeight, widget.projects[index - 1]);
            },
          )),
        ),
        Divider(),
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
                      padding: EdgeInsets.only(bottom: 20),
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
          color: selected ? Theme.of(context).colorScheme.secondaryVariant  : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [selected ? heavyBoxShadow() : slightBoxShadow()],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 20.0, left: 20.0, right: 20),
              child: Text(projectInfo.project,
                  overflow: TextOverflow.fade, maxLines: 2),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: StreamBuilder(
                      stream: projectInfo.logsCount,
                      builder: (context, AsyncSnapshot<int> snapshot) {
                        String count = '';

                        if (snapshot.hasData) {
                          count = snapshot.data.toString();
                        }

                        return Text(count);
                      },
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.only(right: 20.0),
                    child: IconButton(
                        icon: Icon(Icons.archive_outlined, size: 22),
                        onPressed: () {
                          ProjectArchivingService.requestArchiving(
                              context, projectInfo.project);
                        }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logCard(BuildContext context, LogInfoEntity logInfo) {
    var logTextStyle = const TextStyle(
        fontSize: 14.0);
    var title = logInfo.title.splitWordsByLength(kIsWeb ? 64 : 32);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30.0),
      padding: EdgeInsets.all(30.0),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
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
              child: Text(title.item1,
                  overflow: TextOverflow.ellipsis, maxLines: 1, style: logTextStyle),
            ),
            SizedBox(height: 10.0),
            Align(
              alignment: Alignment.topLeft,
              child: Text(title.item2,
                  overflow: TextOverflow.ellipsis, maxLines: 1, style: logTextStyle),
            ),
            SizedBox(height: 5.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(dateFormatter.format(logInfo.createdAt), style: logTextStyle),
                SizedBox(width: 10.0),
                Text(timeFormatter.format(logInfo.createdAt), style: logTextStyle),
                SizedBox(width: 10.0),
                ConditionWidget(
                  condition: kIsWeb,
                  widget: Text(logInfo.author, maxLines: 1, style: logTextStyle),
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
          child: IconButton(icon: Icon(icon, size: 25), onPressed: pressed)),
    );
  }
}
