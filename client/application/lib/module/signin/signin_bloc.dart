import 'dart:async';

import 'package:application/event/login_fail_event.dart';
import 'package:application/event/login_success_event.dart';
import 'package:application/shared/validateInput.dart';
import 'package:flutter/widgets.dart';
import 'package:application/base/base_bloc.dart';
import 'package:application/base/base_event.dart';
import 'package:application/data/repo/user_repo.dart';
import 'package:application/data/spref/spref.dart';
import 'package:application/event/signup_event.dart';
import 'package:application/event/singin_event.dart';
import 'package:application/shared/constant.dart';
import 'package:rxdart/rxdart.dart';

class SignInBloc extends BaseBloc {
  UserRepo _userRepo;
  final _passwordSubject = BehaviorSubject<String>();
  final _usernameSubject = BehaviorSubject<String>();
  final _btnSubject = BehaviorSubject<bool>();

  SignInBloc({@required UserRepo userRepo}) {
    this._userRepo = userRepo;
    combineSubjectToValid();
  }

  var usernameValid = StreamTransformer<String, String>.fromHandlers(
      handleData: (username, sink) {
    if (Validation.isUsernameValid(username)) {
      sink.add(null);
    } else
      sink.add('Username too short');
  });
  var passwordValid = StreamTransformer<String, String>.fromHandlers(
      handleData: (password, sink) {
    if (Validation.isPassValid(password)) {
      sink.add(null);
    } else
      sink.add('Password too short');
  });

  Stream<String> get usernameStream =>
      _usernameSubject.stream.transform(usernameValid);

  Sink<String> get usernameSink => _usernameSubject.sink;

  Stream<String> get passwordStream =>
      _passwordSubject.stream.transform(passwordValid);

  Sink<String> get passwordSink => _passwordSubject.sink;

  Stream<bool> get btnStream => _btnSubject.stream;

  Sink<bool> get btnSink => _btnSubject.sink;

  void combineSubjectToValid() {
    Rx.combineLatest2(_usernameSubject, _passwordSubject, (username, password) {
      return Validation.isPassValid(password) &&
          Validation.isUsernameValid(username);
    }).listen((event) {
      btnSink.add(event);
    });
  }

  @override
  void dispatchEvent(BaseEvent event) {
    switch (event.runtimeType) {
      case SignInEvent:
        handleSignInEvent(event);
        break;
    }
  }

  handleSignInEvent(event) {
    btnSink.add(false);
    loadingSink.add(true);
//    Future.delayed(Duration(seconds: 5), () { //  DELETE THIS ROW
      SignInEvent e = event as SignInEvent;
      _userRepo.signIn(e.username, e.pass).then((user) {
        print('user ne' + user.toString());
        processSink.add(LoginSuccessEvent(user));
      }, onError: (e) {
        btnSink.add(true);
        loadingSink.add(false);
        processSink.add(LoginFailEvent(e.toString()));
        print(e);
      });
//    });  // DELETE THIS ROW TOO
  }

  @override
  void dispose() {
    super.dispose();
    _passwordSubject.close();
    _usernameSubject.close();
    _btnSubject.close();
  }
}
