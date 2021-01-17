import 'package:application/shared/network_image.dart';
import 'package:flutter/material.dart';

enum AlertDialogType {
  SUCCESS,
  ERROR,
  WARNING,
  INFO,
}

class ModelNotification {
  final String title;
  final String body;

  ModelNotification(this.title, this.body);
  factory ModelNotification.fromJson(dynamic json) {
    return ModelNotification(json['title'] as String, json['body'] as String);
  }

  @override
  String toString() {
    return '''{"title":"${title}","body":"${body}"}''';
  }
}

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final Widget icon;
  final String buttonLabel;
  List<ModelNotification> listNotify;

  final TextStyle titleStyle = TextStyle(
      fontSize: 20.0, color: Colors.black, fontWeight: FontWeight.bold);

  CustomAlertDialog(
      {Key key,
      this.title = "Notification",
      @required this.content,
      this.icon,
      this.buttonLabel = "Back",
      this.listNotify})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
        type: MaterialType.transparency,
        child: Container(
          alignment: Alignment.center,
          height: 100,
          child: Container(
            margin: const EdgeInsets.all(8.0),
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(height: 10.0),
                Row(
                  children: [
                    icon ??
                        Icon(
                          Icons.add_alert_sharp,
                          color: Colors.green,
                          size: 30,
                        ),
                    // const SizedBox(height: 10.0),
                    Text(
                      title,
                      style: titleStyle,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Divider(),
                //// ListView
                // Text(
                //   content,
                //   textAlign: TextAlign.center,
                // ),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 200, minHeight: 56.0),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        child: ListTile(
                          leading: FlutterLogo(size: 72.0),
                          title:
                              Text('#${index + 1}: ${listNotify[index].title}'),
                          subtitle: Text('${listNotify[index].body}'),
                          isThreeLine: true,
                        ),
                      );
                    },
                    itemCount: listNotify.length,
                  ),
                ),
                SizedBox(height: 10.0),
                Divider(),
                SizedBox(
                  width: double.infinity,
                  child: FlatButton(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(buttonLabel),
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
