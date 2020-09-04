import 'dart:async';
import 'package:application/base/base_event.dart';
import 'package:application/base/base_widget.dart';
import 'package:application/data/remote/detect_service.dart';
import 'package:application/data/remote/user_service.dart';
import 'package:application/data/repo/detect_repo.dart';
import 'package:application/data/repo/user_repo.dart';
import 'package:application/data/spref/spref.dart';
import 'package:application/event/change_image_cam_event.dart';
import 'package:application/event/change_image_file.dart';
import 'package:application/event/change_image_file_complete.dart';
import 'package:application/event/change_image_file_notpick.dart';
import 'package:application/event/change_image_url_complete.dart';
import 'package:application/event/change_image_url_event.dart';
import 'package:application/event/detect_image_complete.dart';
import 'package:application/event/detect_image_error.dart';
import 'package:application/event/detect_image_event.dart';
import 'package:application/module/home/home_bloc.dart';
import 'package:application/module/signin/signin_page.dart';
import 'package:application/network/server.dart';
import 'package:application/shared/constant.dart';
import 'package:application/shared/widget/bloc_listener.dart';
import 'package:application/shared/widget/loading_task.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PageContainer(
      di: [
        Provider.value(value: UserService()), // Actually, do not need this
        Provider.value(value: DetectService()),
        ProxyProvider<UserService, UserRepo>(
          // do not need this too
          update: (context, userService, previous) =>
              UserRepo(userService: userService),
        ),
        ProxyProvider<DetectService, DetectRepos>(
          update: (context, detectservice, previous) =>
              DetectRepos(detectService: detectservice),
        )
      ],
      bloc: [],
      child: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Attribute for home page
  File _imageFile;
  Uint8List _base64;
  StringBuffer _urlPicture;

  final Color color1 = Hexcolor("#9CC9F5"); //Color.fromRGBO(252, 119, 3, 1);
  final Color color2 = Colors.lightBlueAccent; //Color.fromRGBO(252, 244, 3, 1);
  TextEditingController _c;

  Uri apiUrl;
  String dropdownValue;
  var _isDetecting = false;
  var hasModels = false;
  List<String> listModelNames;

  @override
  void initState() {
    _urlPicture = null;//new StringBuffer();
    checkLoginStatusAndIP();
    initForDropdown();
    super.initState();

  }

  checkLoginStatusAndIP() async {
    var ip = await SPref.instance.get(SPrefCache.CURRENT_IP_SERVER);
    if(ip!=null) {
      DetectClient.setServerIP(ip);
    }
    var token = await SPref.instance.get(SPrefCache.KEY_TOKEN);
    if (token == null || ip==null) {
      print("Token null or ip null");
      Navigator.of(context).pushAndRemoveUntil(
          new MaterialPageRoute(builder: (BuildContext context) => SignIn()),
          (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    _c = new TextEditingController(); // RGBA rgba( 1)
    return Scaffold(
      body: _buildHomepageView(context),
    );
  }

  _buildHomepageView(BuildContext context) {
    return Provider<HomePageBloc>.value(
      value: HomePageBloc(detectRepos: Provider.of(context)),
      child: Consumer<HomePageBloc>(
        builder: (context, bloc, child) => BlocListener<HomePageBloc>(
          listener: handleHomepageEvent,
          child: LoadingTask(
            bloc: bloc,
            child: Stack(
              children: <Widget>[
                Container(
                  height: 360,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(50.0),
                          bottomRight: Radius.circular(50.0)),
                      gradient: LinearGradient(
                          colors: [color1, color2],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  //change here don't //worked
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (hasModels == true) _buildDropdownList(bloc),
                    new Spacer(),
                    Container(
                      margin: const EdgeInsets.only(top: 30, right: 10),
                      child: FlatButton(
                        onPressed: () {
                          SPref.instance.set(SPrefCache.KEY_TOKEN, null);
                          SPref.instance.set(SPrefCache.MODEL_NAMES, null);
                          Navigator.pushReplacementNamed(context, '/home');
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40.0)),
                        color: Colors.black12,
                        child: Text("Log out",
                            style:
                                TextStyle(color: Colors.black, fontSize: 18.0)),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 60),
                  height: 600,
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 20.0),
                      Expanded(
                        child: Stack(
                          children: <Widget>[
                            Container(
                                height: double.infinity,
                                margin: const EdgeInsets.only(
                                    left: 30.0, right: 30.0, top: 10.0),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(30.0),
                                    child: _decideImage(base: _base64)))
                          ],
                        ),
                      ),
                      SizedBox(height: 30.0),
                      Container(
                        child: Stack(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 16.0),
                              margin: const EdgeInsets.only(
                                  top: 30,
                                  left: 20.0,
                                  right: 20.0,
                                  bottom: 20.0),
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [color1, color2],
                                  ),
                                  borderRadius: BorderRadius.circular(30.0)),
                              child: Row(
                                children: <Widget>[
                                  IconButton(
                                    color: Colors.white,
                                    icon: Icon(FontAwesomeIcons.link),
                                    onPressed: () {
                                      showDialog(
                                          child: Dialog(
                                            child: Column(
                                              children: <Widget>[
                                                _buildInputURL(context, bloc),
                                                _buildButtonUseImage(
                                                    context, bloc)
                                              ],
                                            ),
                                          ),
                                          context: context);
                                    },
                                  ),
                                  Spacer(),
                                  IconButton(
                                    color: Colors.white,
                                    icon: Icon(Icons.image),
                                    onPressed: () {
                                      _showChoiceDialog(context, bloc);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Center(
                              child: _buildButtonDetectImage(context, bloc),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showChoiceDialog(BuildContext context, HomePageBloc bloc) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Choose your image'),
            content: SingleChildScrollView(
                child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Text("Gallery"),
                  onTap: () {
                    bloc.event.add(ChangeImgInGallery(context: context));
                  },
                ),
                Padding(padding: EdgeInsets.all(8)),
                GestureDetector(
                  child: Text("Camera"),
                  onTap: () {
                    bloc.event.add(ChangeImgByCamera(context: context));
                  },
                )
              ],
            )),
          );
        });
  }

  Widget _decideImage({Uint8List base}) {
    if (base != null)
      return PhotoView(
        imageProvider: new Image.memory(
          base,
          width: 400,
          height: 400,
        ).image,
      );
    if (_urlPicture != null && _urlPicture.toString().length > 5) {
      String url = _urlPicture.toString();
      try {
        print('url pic not null $url');
        return CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) {
            _urlPicture = null;
            return Image(
              image: AssetImage('assets/no_img.png'),
            );
          },
        );
      } catch (e) {
        return Image(
          image: AssetImage('assets/no_img.png'),
        );
      }
    }
    if (_imageFile == null)
      return Image.asset(
        'assets/no_img.png',
        width: 400,
        height: 400,
      );
    print('file ');
    return PhotoView(
        imageProvider: Image.file(_imageFile, fit: BoxFit.cover).image);
  }

  _buildButtonDetectImage(BuildContext context, HomePageBloc bloc) {
    return FloatingActionButton(
      heroTag: 'Detection',
      child: Icon(
        Icons.remove_red_eye,
        color: Colors.pink,
      ),
      backgroundColor: Colors.white,
      onPressed: _isDetecting != true
          ? () {
              print('clicked');
              if( dropdownValue == null || dropdownValue.length<1)
                {_buildSnackBar(context, "No model selected", Colors.red);  return;}

              if (_urlPicture != null) {
                print('send url event');
                _isDetecting = true;
                bloc.event.add(DetectImageEvent(
                    modelName: dropdownValue,
                    urlImage: _urlPicture.toString()));
              } else if (_imageFile != null) {
                print('send file event');
                _isDetecting = true;
                bloc.event.add(DetectImageEvent(
                    modelName: dropdownValue, fileImage: _imageFile));
              }
            }
          : null,
    );
  }

  _buildButtonUseImage(BuildContext context, HomePageBloc bloc) {
    return StreamProvider<bool>.value(
      initialData: false,
      value: bloc.btnChangeImgURStream,
      child: Consumer<bool>(
        builder: (context, enable, child) => FlatButton(
          child: new Text("Use this link"),
          color: Colors.lightBlueAccent,
          padding: EdgeInsets.all(10.0),
          onPressed: enable
              ? () {
                  print('change url');
                  bloc.event.add(ChangeImgURL(
                      newURL: _c.text)); //, bufferURL: this._urlPicture));
                  Navigator.pop(context);
                }
              : null,
        ),
      ),
    );
  }

  _buildInputURL(BuildContext context, HomePageBloc bloc) {
    return StreamProvider<String>.value(
      initialData: null,
      value: bloc.urlStream,
      child: Consumer<String>(
        builder: (context, msg, child) => new TextField(
          decoration:
              new InputDecoration(hintText: "Image url", errorText: msg),
          controller: _c,
          onChanged: (text) {
            bloc.urlSink.add(text);
          },
          onSubmitted: (value) {},
        ),
      ),
    );
  }

  _buildDropdownList(HomePageBloc bloc) {
    return Container(
      margin: const EdgeInsets.only(top: 15, left: 20),
      child: DropdownButton<String>(
        value: dropdownValue,
        icon: Icon(Icons.arrow_downward),
        iconSize: 24,
        elevation: 16,
        style: TextStyle(color: Colors.deepPurple),
        underline: Container(
          height: 2,
          color: Colors.deepPurpleAccent,
        ),
        onChanged: (String newValue) {
          setState(() {
            dropdownValue = newValue;
          });
        },
        items: listModelNames.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  handleHomepageEvent(BaseEvent event) {
    if (event is ChangeImgURLComplete) {
      setState(() {
        _urlPicture = event.buffer;
        _base64 = null;
        _imageFile = null;
      });
      _buildSnackBar(context, 'Change url image complete', Colors.green);
    }
    if (event is ChangeImgFileComplete) {
      setState(() {
        _urlPicture = null;
        _imageFile = event.imageFile;
        _base64 = null;
      });
      _buildSnackBar(context, 'Change file image complete', Colors.green);
    }
    if (event is ChangeImgFileNotPick) {
      _buildSnackBar(context, 'Cancel choose image', Colors.grey);
    }
    if (event is DetectImageComplete) {
      _isDetecting = false;
      _buildSnackBar(context, "Detect complete", Colors.green);
      setState(() {
        _base64 = event.bytesImage;
      });
    }
    if (event is DetectImageError) {
      _isDetecting = false;
      _buildSnackBar(context, "Error due to ${event.message}", Colors.red);
    }
  }

  _buildSnackBar(BuildContext context, String message, MaterialColor color) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: color,
      duration: Duration(seconds: 3),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  initForDropdown() async {
    String stringModelNames = await SPref.instance.get(SPrefCache.MODEL_NAMES);
    if (stringModelNames != null) {
      print("LIST NOT NULL");
      listModelNames = stringModelNames.split(",");
      dropdownValue = listModelNames[0];
      hasModels = true;
    }
  }
}
