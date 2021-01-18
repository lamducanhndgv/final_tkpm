import 'package:application/base/base_event.dart';
import 'package:application/data/spref/spref.dart';
import 'package:application/event/loginpage_change_ip_complete.dart';
import 'package:application/event/loginpage_change_ip_event.dart';
import 'package:application/event/loginpage_login_fail_event.dart';
import 'package:application/event/loginpage_login_success_event.dart';
import 'package:application/network/server.dart';
import 'package:application/shared/assets.dart';
import 'package:application/shared/constant.dart';
import 'package:application/shared/network_image.dart';
import 'package:application/shared/widget/bloc_listener.dart';
import 'package:application/shared/widget/loading_task.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:application/base/base_widget.dart';
import 'package:application/data/remote/user_service.dart';
import 'package:application/data/repo/user_repo.dart';
import 'package:application/event/loginpage_singin_event.dart';
import 'package:application/module/signin/signin_bloc.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class SignIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PageContainer(
      di: [
        // using dependency injection
        Provider.value(value: UserService()),
        // ignore: missing_required_param
        ProxyProvider<UserService, UserRepo>(
          // ignore: deprecated_member_use
          builder: (context, userService, previous) =>
              UserRepo(userService: userService),
        )
      ],
      bloc: [],
      child: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cServer = TextEditingController();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  var deviceToken;

  _register() {
    _firebaseMessaging.getToken().then((token) {
      deviceToken = token;
      print('here is your token: ' + deviceToken);
    });
  }



  handleLoginEvent(BaseEvent event) {
    if (event is LoginSuccessEvent) {
      Navigator.pushReplacementNamed(context, '/home');
      return;
    }
    if (event is LoginFailEvent) {
      final snackBar = SnackBar(
        content: Text(event.errMessage),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      );
      Scaffold.of(context).showSnackBar(snackBar);
    }
    if (event is ChangeIPComplete) {
      final snackBar = SnackBar(
        content: Text('Change server address complete'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      );
      Scaffold.of(context).showSnackBar(snackBar);
    }
  }

  @override
  void initState() {
    super.initState();
    initForOldIP();
    _register();
  }

  bool _visible = false;

  Widget _buildPageContent(BuildContext context) {
    return Provider<SignInBloc>.value(
      value: SignInBloc(userRepo: Provider.of(context)),
      child: Consumer<SignInBloc>(builder: (context, bloc, child) {
        return BlocListener<SignInBloc>(
            listener: handleLoginEvent,
            child: LoadingTask(
                bloc: bloc,
                child: Container(
                  color: Colors.blue.shade100,
                  child: ListView(
                    children: <Widget>[
                      _buildChangeIPRow(bloc),
                      SizedBox(
                        height: 10.0,
                      ),
                      CircleAvatar(
                        child: PNetworkImage(origami),
                        maxRadius: 50,
                        backgroundColor: Colors.transparent,
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      _buildLoginForm(bloc),
                      _buildSignUpButton(context)
                    ],
                  ),
                )));
      }),
    );
  }

  Row _buildSignUpButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.pushNamed(context, '/register');
          },
          child: Text("Sign Up",
              style: TextStyle(color: Colors.blue, fontSize: 18.0)),
        )
      ],
    );
  }

  Row _buildChangeIPRow(SignInBloc bloc) {
    return Row(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 5),
          child: FloatingActionButton(
            heroTag: 'ClickRemoteServer',
            foregroundColor: Colors.black54,
            backgroundColor: Colors.yellow[250],
            elevation: 2.0,
            child: Icon(Icons.settings_remote),
            onPressed: () {
              setState(() {
                _visible = !_visible;
              });
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 10, left: 10),
          child: AnimatedOpacity(
            // If the widget is visible, animate to 0.0 (invisible).
            // If the widget is hidden, animate to 1.0 (fully visible).
              opacity: _visible ? 1.0 : 0.0,
              duration: Duration(milliseconds: 1000),
              // The green box must be a child of the AnimatedOpacity widget.
              child: Row(
                children: [
                  Container(
                    width: 200.0,
                    height: 50.0,
                    color: Colors.white,
                    child: _buildChangeIP(bloc),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: _buildButtonChange(bloc),
                  ),
                ],
              )),
        ),
      ],
    );
  }

  _buildButtonChange(SignInBloc bloc) {
    return StreamProvider<bool>.value(
      initialData: false,
      value: bloc.btnChangeStream,
      child: Consumer<bool>(
        builder: (context, enable, child) =>
            FloatingActionButton(
                heroTag: 'Server',
                foregroundColor: Colors.black54,
                backgroundColor: Colors.yellow[250],
                elevation: 2.0,
                child: Icon(FontAwesomeIcons.arrowRight),
                onPressed: enable
                    ? () {
                  bloc.event.add(ChangeIPEvent(newIP: _cServer.text));
                  setState(() {
                    _visible = !_visible;
                  });
                }
                    : null),
      ),
    );
  }

  _buildChangeIP(SignInBloc bloc) {
    return StreamProvider<String>.value(
      initialData: null,
      value: bloc.ipStream,
      child: Consumer<String>(
        builder: (context, msg, child) =>
            TextField(
              textInputAction: TextInputAction.go,
              decoration: new InputDecoration(
                hintText: "192.168.",
                errorText: msg,
              ),
              controller: _cServer,
              onChanged: (value) {
                bloc.ipSink.add(value);
              },
              onSubmitted: (value) {},
            ),
      ),
    );
  }

  Container _buildLoginForm(SignInBloc bloc) {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: Stack(
        children: <Widget>[
          ClipPath(
            clipper: RoundedDiagonalPathClipper(),
            child: Container(
              height: 350,
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(40.0)),
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 70.0,
                  ),
                  _buildUserName(bloc),
                  Container(
                    child: Divider(
                      color: Colors.blue.shade400,
                    ),
                    padding:
                    EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
                  ),
                  _buildPassword(bloc),
                  Container(
                    child: Divider(
                      color: Colors.blue.shade400,
                    ),
                    padding:
                    EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                radius: 40.0,
                backgroundColor: Colors.blue.shade600,
                child: Icon(Icons.person),
              ),
            ],
          ),
          Container(
            height: 370,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: _buildLoginButton(bloc),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPageContent(context),
    );
  }

  _buildLoginButton(SignInBloc bloc) {
    return StreamProvider<bool>.value(
      initialData: false,
      value: bloc.btnStream,
      child: Consumer<bool>(
        builder: (context, enable, child) =>
            RaisedButton(
              onPressed: enable
                  ? () {
                print('clicked');
                bloc.event.add(SignInEvent(
                    username: _usernameController.text,
                    pass: _passwordController.text,
                    tokenDevice:deviceToken
                ));
              }
                  : null,
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
              child: Text("Login", style: TextStyle(color: Colors.white70)),
              color: Colors.blue,
            ),
      ),
    );
  }

  _buildUserName(SignInBloc bloc) {
    return StreamProvider<String>.value(
      initialData: null,
      value: bloc.usernameStream,
      child: Consumer<String>(
        builder: (context, msg, child) =>
            Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  controller: _usernameController,
                  style: TextStyle(color: Colors.blue),
                  onChanged: (text) {
                    bloc.usernameSink.add(text);
                  },
                  decoration: InputDecoration(
                      hintText: "Username",
                      errorText: msg,
                      hintStyle: TextStyle(color: Colors.blue.shade200),
                      border: InputBorder.none,
                      icon: Icon(
                        Icons.account_circle,
                        color: Colors.blue,
                      )),
                )),
      ),
    );
  }

  _buildPassword(SignInBloc bloc) {
    return StreamProvider<String>.value(
      initialData: null,
      value: bloc.passwordStream,
      child: Consumer<String>(
        builder: (context, msg, child) =>
            Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  obscureText: true,
                  onChanged: (text) {
                    bloc.passwordSink.add(text);
                  },
                  onSubmitted: (text) {},
                  //Set listener for password
                  controller: _passwordController,
                  style: TextStyle(color: Colors.blue),
                  decoration: InputDecoration(
                      hintText: "Password",
                      errorText: msg,
                      hintStyle: TextStyle(color: Colors.blue.shade200),
                      border: InputBorder.none,
                      icon: Icon(
                        Icons.lock,
                        color: Colors.blue,
                      )),
                )),
      ),
    );
  }

  initForOldIP() async {
    var oldIP = await SPref.instance.get(SPrefCache.CURRENT_IP_SERVER);
    if (oldIP != null) {
      print('Set ip to $oldIP by spref');
      DetectClient.setServerIP(oldIP);
    }
  }
}
