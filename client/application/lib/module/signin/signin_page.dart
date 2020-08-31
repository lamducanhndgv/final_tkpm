import 'package:application/base/base_event.dart';
import 'package:application/event/login_fail_event.dart';
import 'package:application/event/login_success_event.dart';
import 'package:application/module/signup/signup_page.dart';
import 'package:application/shared/assets.dart';
import 'package:application/shared/network_image.dart';
import 'package:application/shared/widget/bloc_listener.dart';
import 'package:application/shared/widget/loading_task.dart';
import 'package:flutter/material.dart';
import 'package:application/base/base_widget.dart';
import 'package:application/data/remote/user_service.dart';
import 'package:application/data/repo/user_repo.dart';
import 'package:application/event/singin_event.dart';
import 'package:application/module/signin/signin_bloc.dart';
import 'package:application/shared/app_color.dart';
import 'package:application/shared/widget/normal_button.dart';
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
        ProxyProvider<UserService, UserRepo>(
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

  handleLoginEvent(BaseEvent event) {
    if(event is LoginSuccessEvent){
      Navigator.pushReplacementNamed(context, '/home');
      return;
    }
    if(event is LoginFailEvent){
      final snackBar= SnackBar(
        content : Text(event.errMessage),
        backgroundColor: Colors.red,
      );
      Scaffold.of(context).showSnackBar(snackBar);

    }
  }
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
                      SizedBox(
                        height: 30.0,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          FlatButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            child: Text("Sign Up",
                                style: TextStyle(
                                    color: Colors.blue, fontSize: 18.0)),
                          )
                        ],
                      )
                    ],
                  ),
                )));
      }),
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
              height: 400,
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(40.0)),
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 90.0,
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
            height: 420,
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
        builder: (context, enable, child) => RaisedButton(
          onPressed: enable
              ? () {
                  print('clicked');
                  bloc.event.add(SignInEvent(
                    username: _usernameController.text,
                    pass: _passwordController.text,
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
        builder: (context, msg, child) => Container(
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
        builder: (context, msg, child) => Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              obscureText: true,
              onChanged: (text) {
                bloc.passwordSink.add(text);
              },
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

}
