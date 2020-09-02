import 'dart:async';

import 'package:application/event/change_ip_complete.dart';
import 'package:application/event/change_ip_event.dart';
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
  final _ipSubject = BehaviorSubject<String>();
  final _btnChangeIPSubject = BehaviorSubject<bool>();

  SignInBloc({@required UserRepo userRepo}) {
    this._userRepo = userRepo;
    combineSubjectToValid();
    combineChangeIP();
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
  var ipValid = StreamTransformer<String, String>.fromHandlers(
      handleData: (ipAddress, sink) {
        if (Validation.isIPvalid(ipAddress))
      sink.add(null);
    else
      sink.add("IP invalid");
  });

  Stream<String> get usernameStream =>
      _usernameSubject.stream.transform(usernameValid);

  Sink<String> get usernameSink => _usernameSubject.sink;

  Stream<String> get passwordStream =>
      _passwordSubject.stream.transform(passwordValid);

  Sink<String> get passwordSink => _passwordSubject.sink;

  Stream<bool> get btnStream => _btnSubject.stream;

  Sink<bool> get btnSink => _btnSubject.sink;

  Stream<String> get ipStream => _ipSubject.stream.transform(ipValid);

  Stream<bool> get btnChangeStream => _btnChangeIPSubject.stream;

  Sink<String> get ipSink => _ipSubject.sink;

  Sink<bool> get btnChangeSink => _btnChangeIPSubject.sink;

  void combineSubjectToValid() {
    Rx.combineLatest2(_usernameSubject, _passwordSubject, (username, password) {
      return Validation.isPassValid(password) &&
          Validation.isUsernameValid(username);
    }).listen((event) {
      btnSink.add(event);
    });
  }

  combineChangeIP() {
    Rx.combineLatest([_ipSubject], (values) {
      return values.join("");
    }).listen((event) {
      if (Validation.isIPvalid(event.toString())) {
        btnChangeSink.add(true);
      } else {
        btnChangeSink.add(false);
      }
    });
  }

  @override
  void dispatchEvent(BaseEvent event) {
    print(event.toString());
    switch (event.runtimeType) {
      case SignInEvent:
        handleSignInEvent(event);
        break;
      case ChangeIPEvent:
        handleChangeIPEvent(event);
        break;
    }
  }

  handleChangeIPEvent(BaseEvent event) async{
    ChangeIPEvent e = event as ChangeIPEvent;
    print('Call change from bloc');
    await _userRepo.changeServerAddress(e.newIP);
    processSink.add(ChangeIPComplete());
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
    _ipSubject.close();
    _btnChangeIPSubject.close();
  }
}
