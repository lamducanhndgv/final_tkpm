import 'package:application/base/base_event.dart';
import 'package:application/event/registerpage_register_fail_event.dart';
import 'package:application/event/registerpage_register_success_event.dart';
import 'package:application/event/registerpage_signup_event.dart';
import 'package:application/module/signup/signup_bloc.dart';
import 'package:application/shared/assets.dart';
import 'package:application/shared/models/ConfirmType.dart';
import 'package:application/shared/network_image.dart';
import 'package:application/shared/widget/bloc_listener.dart';
import 'package:application/shared/widget/loading_task.dart';
import 'package:flutter/material.dart';
import 'package:application/base/base_widget.dart';
import 'package:application/data/remote/user_service.dart';
import 'package:application/data/repo/user_repo.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PageContainer(
      di: [
        // dependency injection
        Provider.value(value: UserService()),
        // ignore: missing_required_param
        ProxyProvider<UserService, UserRepo>(
          // ignore: deprecated_member_use
          builder: (context, userService, previous) =>
              UserRepo(userService: userService),
        )
      ],
      bloc: [],
      child: SignupPage(),
    );
  }
}

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController usernameController = TextEditingController();

  TextEditingController confirmController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  Widget _buildPageContent(BuildContext context) {
    return Provider<SignUpBloc>.value(
      value: SignUpBloc(userRepo: Provider.of(context)),
      child: Consumer<SignUpBloc>(
        builder: (context, bloc, child) {
          return BlocListener<SignUpBloc>(
              listener: handleRegisterEvent,
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
                        _buildBackButton(context)
                      ],
                    ),
                  )));
        },
      ),
    );
  }

  Row _buildBackButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        FloatingActionButton(
          mini: true,
          onPressed: () {
            Navigator.pop(context);
          },
          backgroundColor: Colors.blue,
          child: Icon(Icons.arrow_back),
        )
      ],
    );
  }

  _buildLoginForm(bloc) {
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
                  _buildUsernameForm(bloc),
                  Container(
                    child: Divider(
                      color: Colors.blue.shade400,
                    ),
                    padding:
                        EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
                  ),
                  _buildPasswordForm(bloc),
                  Container(
                    child: Divider(
                      color: Colors.blue.shade400,
                    ),
                    padding:
                        EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
                  ),
                  _buildConfirmForm(bloc),
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
          _buildButtonSignup(bloc)
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

  _buildUsernameForm(SignUpBloc bloc) {
    return StreamProvider<String>.value(
      initialData: null,
      value: bloc.userStream,
      child: Consumer<String>(
        builder: (context, msg, child) => Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              controller: usernameController,
              style: TextStyle(color: Colors.blue),
              onChanged: (text) {
                bloc.userSink.add(text);
              },
              decoration: InputDecoration(
                  hintText: "Username",
                  errorText: msg,
                  hintStyle: TextStyle(color: Colors.blue.shade200),
                  border: InputBorder.none,
                  icon: Icon(
                    Icons.person,
                    color: Colors.blue,
                  )),
            )),
      ),
    );
  }

  _buildPasswordForm(SignUpBloc bloc) {
    return StreamProvider<String>.value(
      initialData: null,
      value: bloc.passwordStream,
      child: Consumer<String>(
        builder: (context, msg, child) => Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              controller: passwordController,
              obscureText: true,
              onChanged: (text) {
                bloc.passwordSink.add(text);
              },
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

  _buildConfirmForm(SignUpBloc bloc) {
    return StreamProvider<ConfirmType>.value(
      initialData: null,
      value: bloc.confirmStream,
      child: Consumer<ConfirmType>(
        builder: (context, msg, child) => Flexible(
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                controller: confirmController,
                style: TextStyle(color: Colors.blue),
                obscureText: true,
                onChanged: (text) {
                  print('confirm change');
                  bloc.confirmSink.add(ConfirmType(
                      password: passwordController.text, confirm: text));
                },
                decoration: InputDecoration(
                    hintText: "Confirm password",
                    errorText: msg != null ? msg.toString() : null,
                    hintStyle: TextStyle(color: Colors.blue.shade200),
                    border: InputBorder.none,
                    icon: Icon(
                      Icons.lock,
                      color: Colors.blue,
                    )),
              )),
        ),
      ),
    );
  }

  _buildButtonSignup(SignUpBloc bloc) {
    return StreamProvider<bool>.value(
      initialData: false,
      value: bloc.btnStream,
      child: Consumer<bool>(
        builder: (context, enable, child) => Container(
          height: 420,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: RaisedButton(
              onPressed: enable
                  ? () {
                      print('clicked');
                      bloc.event.add(SignUpEvent(
                          username: usernameController.text,
                          pass: passwordController.text));
                    }
                  : null,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0)),
              child: Text("Sign Up", style: TextStyle(color: Colors.white70)),
              color: Colors.blue,
            ),
          ),
        ),
      ),
    );
  }

  handleRegisterEvent(BaseEvent event) {
    if (event is RegisterSuccess) {
      final snackBar = SnackBar(
        content: Text('Register Success'),
        backgroundColor: Colors.green,
      );
      Scaffold.of(context).showSnackBar(snackBar);
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pop(context);
        return;
      });
    }
    if (event is RegisterFail) {
      final snackBar = SnackBar(
        content: Text(event.errMessage),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      );
      Scaffold.of(context).showSnackBar(snackBar);
    }
  }
}
