import 'dart:async';

import 'package:application/base/base_bloc.dart';
import 'package:application/base/base_event.dart';
import 'package:application/data/repo/user_repo.dart';
import 'package:application/event/register_fail_event.dart';
import 'package:application/event/register_success_event.dart';
import 'package:application/event/signup_event.dart';
import 'package:application/shared/validateInput.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rxdart/rxdart.dart';

class SignUpBloc extends BaseBloc {
  final _username = BehaviorSubject<String>();
  final _password = BehaviorSubject<String>();
  final _confirmPass = BehaviorSubject<String>();
  final _btnSignUp = BehaviorSubject<bool>();
  UserRepo _userRepo;

  SignUpBloc({@required UserRepo userRepo}) {
    this._userRepo = userRepo;
    combineFormRegister();
  }

  combineFormRegister() {
    Rx.combineLatest3(_username, _password, _confirmPass,
        (username, password, confirm) {
      return Validation.isPassValid(password) &&
          Validation.isUsernameValid(username) &&
          Validation.isPassValid(confirm) &&
          ( password.compareTo(confirm)==0);
    }).listen((event) {
      btnSink.add(event);
    });
  }

  var userValidate = StreamTransformer<String, String>.fromHandlers(
      handleData: (username, sink) {
    if (Validation.isUsernameValid(username)) {
      sink.add(null);
    } else
      sink.add('Username invalid');
  });
  var passValidate = StreamTransformer<String, String>.fromHandlers(
      handleData: (password, sink) {
    if (Validation.isPassValid(password)) {
      sink.add(null);
    } else
      sink.add('Password too short');
  });
  // Want to check match password but can not do ? ?
  var confirmValidate = StreamTransformer<String, String>.fromHandlers(
      handleData: (confirm, sink) {
    if (Validation.isPassValid(confirm)) {
      sink.add(null);
    } else
      sink.add('Password too short');
  });

  Stream<String> get userStream => _username.stream.transform(userValidate);

  Sink<String> get userSink => _username.sink;

  Stream<String> get passwordStream => _password.stream.transform(passValidate);

  Sink<String> get passwordSink => _password.sink;

  Stream<String> get confirmStream => _confirmPass.stream.transform(confirmValidate);

  Sink<String> get confirmSink => _confirmPass.sink;

  Stream<bool> get btnStream => _btnSignUp.stream;

  Sink<bool> get btnSink => _btnSignUp.sink;

  @override
  void dispatchEvent(BaseEvent event) {
    switch (event.runtimeType) {
      case SignUpEvent:
        handleSignUpEvent(event);
        break;
    }
  }

  handleSignUpEvent(BaseEvent event) {
    btnSink.add(false);
    loadingSink.add(true);
    SignUpEvent e = event as SignUpEvent;
    _userRepo.signUp(e.username, e.pass).then((user) {
      loadingSink.add(false);
      processSink.add(RegisterSuccess());
    }, onError: (e) {
      btnSink.add(true);
      loadingSink.add(false);
      processSink.add(RegisterFail(e.toString()));
      print(e);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _confirmPass.close();
    _username.close();
    _password.close();
    _btnSignUp.close();
  }
}
