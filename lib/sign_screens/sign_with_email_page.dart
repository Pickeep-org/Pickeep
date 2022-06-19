// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pickeep/firebase_authentication/firebase_authentication_notifier.dart';
import 'package:pickeep/firebase_authentication/firebase_email_authentication.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class SignWithEmailScreen extends StatefulWidget {
  final bool is_registered_user;

  SignWithEmailScreen({Key? key, required this.is_registered_user}) : super(key: key);

  @override
  State<SignWithEmailScreen> createState() => _SignWithEmailScreenState();
}

class _SignWithEmailScreenState extends State<SignWithEmailScreen> {
  final TextEditingController _emailTextEditingController;
  final TextEditingController _passwordTextEditingController;
  final TextEditingController _confirmPasswordTextEditingController;
  bool _passwordVisibility = false;
  bool _confirmPasswordVisibility = false;

  _SignWithEmailScreenState()
      : _emailTextEditingController = TextEditingController(),
        _passwordTextEditingController = TextEditingController(),
        _confirmPasswordTextEditingController = TextEditingController();

  late FocusNode _passwordFocusNode;
  late FocusNode _confirmPasswordFocusNode;

  final _formKey = GlobalKey<FormState>();

  String? _emailErrorMessage;
  String? _passwordErrorMessage;
  String? _confrimPasswordErrorMessage;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    _passwordFocusNode = FocusNode();
    _confirmPasswordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        //automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(
            widget.is_registered_user
                ? 'Sign in with email'
                : 'Sign up with email',
          )),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Column(
                children: [
                  TextFormField(
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailTextEditingController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(
                        Icons.email,
                      ),
                    ),
                    onEditingComplete: () =>
                        _passwordFocusNode.requestFocus(),
                    validator: (value) {
                      if (_emailErrorMessage != null) {
                        return _emailErrorMessage;
                      } else if (value == '') {
                        return 'Email can\'t be empty';
                      }
                    },
                  ),
                  TextFormField(
                    focusNode: _passwordFocusNode,
                    obscureText: !_passwordVisibility,
                    controller: _passwordTextEditingController,
                    autocorrect: false,
                    textInputAction: widget.is_registered_user
                        ? TextInputAction.done
                        : TextInputAction.next,
                    decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(
                          Icons.lock,
                        ),
                        suffixIcon: IconButton(
                          icon: _passwordVisibility
                              ? const Icon(Icons.visibility_off)
                              : const Icon(Icons.visibility),
                          onPressed: () => setState(() =>
                          _passwordVisibility = !_passwordVisibility),
                        )),
                    validator: (value) {
                      if (_passwordErrorMessage != null) {
                        return _passwordErrorMessage;
                      } else if (value == '') {
                        return 'Password can\'t be empty. Please fill password field';
                      }
                    },
                    onEditingComplete: widget.is_registered_user
                        ? null
                        : () => _confirmPasswordFocusNode.requestFocus(),
                  ),
                  Visibility(
                    child: TextFormField(
                      focusNode: _confirmPasswordFocusNode,
                      obscureText: !_confirmPasswordVisibility,
                      controller: _confirmPasswordTextEditingController,
                      autocorrect: false,
                      decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(
                            Icons.lock,
                          ),
                          suffixIcon: IconButton(
                            icon: _confirmPasswordVisibility
                                ? const Icon(Icons.visibility_off)
                                : const Icon(Icons.visibility),
                            onPressed: () => setState(() =>
                            _confirmPasswordVisibility =
                            !_confirmPasswordVisibility),
                          )),
                      validator: widget.is_registered_user
                          ? null
                          : (value) {
                        if (_confrimPasswordErrorMessage != null) {
                          return _confrimPasswordErrorMessage;
                        } else if (value == '') {
                          return 'Confirm password can\'t be empty. Please fill password field';
                        } else if (_passwordTextEditingController
                            .text !=
                            _confirmPasswordTextEditingController
                                .text) {
                          return 'The passwords do not match';
                        }
                      },
                    ),
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    visible: !widget.is_registered_user,
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: onPressedSign,
                child: Text(
                  widget.is_registered_user ? 'Sign in' : 'Sign up',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration buildPasswordInputDecoration(bool showPassword) {
    return InputDecoration(
        labelText: 'Password',
        prefixIcon: Icon(
          Icons.lock,
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.visibility),
          onPressed: () => setState(() => showPassword = !showPassword),
        ));
  }

  Future onPressedSign() async {
    final email = _emailTextEditingController.text;
    final password = _passwordTextEditingController.text;

    _emailErrorMessage = null;
    _passwordErrorMessage = null;
    _confrimPasswordErrorMessage = null;

    if (_formKey.currentState!.validate() &&
        (widget.is_registered_user ||
            _passwordTextEditingController.text ==
                _confirmPasswordTextEditingController.text)) {
      try {
        FirebaseEmailAuthentication firebaseEmailAuthentication =
        FirebaseEmailAuthentication.instance();
        firebaseEmailAuthentication.initInstance(
            email: email,
            password: password,
            isRegisteredUser: widget.is_registered_user);

        final firebaseAuthenticationNotifier =
        Provider.of<FirebaseAuthenticationNotifier>(context, listen: false);

        firebaseAuthenticationNotifier
            .setFirebaseAuthentication(firebaseEmailAuthentication);

        // TODO:
        await firebaseAuthenticationNotifier.signIn();

        // TODO:
        // Navigator.of(context).pushAndRemoveUntil(
        //     MaterialPageRoute(
        //         builder: (BuildContext context) => HomeScreen()),
        //         (route) => false);


      } on FirebaseAuthException catch (e) {
        if (e.code == 'invalid-email') {
          _emailErrorMessage = 'Invalid email.';
        } else if (e.code == 'weak-password') {
          _passwordErrorMessage = e.message;
        } else if (e.code == 'email-already-in-use') {
          _emailErrorMessage = 'An account already exists for that email.';
        } else if (e.code == 'wrong-password' || e.code == 'user-not-found') {
          _emailErrorMessage = 'The email or password is incorrect';
          _passwordErrorMessage = 'The email or password is incorrect';
        } else {
          _emailErrorMessage = e.message;
        }

        _formKey.currentState!.validate();
      } catch (e) {
        _emailErrorMessage = 'Connection error please try again later';
        _formKey.currentState!.validate();
      }
    }
  }
}
