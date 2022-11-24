import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pickeep/firebase_authentication/firebase_authentication_notifier.dart';
import 'package:pickeep/firebase_authentication/firebase_email_authentication.dart';
import 'package:pickeep/main.dart';
import 'package:pickeep/sign_screens/reset_password_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

// Handles the signing up of a new user or signing in of a existing user using email
// authentication method. this class wrap the Firebase Email Authentication (3.3).
// Class fields:
// 1. bool isregistereduser
// 2. Text Controllers - hold the information given by the user.
// 3. Focus Nodes - Part of the UI, handling the inserting text flow experience.
// 4. bool isButtonEnabled - True after all fields are filled and legal.
// 5. String formKey - used for validating all of TextFormField widgets in the
// form.
// 6. String emailErrorMessage
// 7. String passwordErrorMessage
// 8. String confrimPasswordErrorMessage
class SignWithEmailScreen extends StatefulWidget {
  final bool isRegisteredUser;

  const SignWithEmailScreen({Key? key, required this.isRegisteredUser})
      : super(key: key);

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

  bool _isButtonEnabled = false;

  final _formKey = GlobalKey<FormState>();

  String? _emailErrorMessage;
  String? _passwordErrorMessage;
  String? _confirmPasswordErrorMessage;

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

  showAlertDialog(BuildContext context) {
    Widget okButton = TextButton(
      child: const Text("Ok"),
      onPressed: () {
        Navigator.of(context).pop(true);
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Hello"),
      content: const Text(
          "A verification mail has been sent to your email, please check your mailbox for further instructions before signing in"),
      actions: [
        okButton,
      ],
    );
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          //automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(
            widget.isRegisteredUser
                ? 'Sign in with email'
                : 'Sign up with email',
          )),
      body: Form(
        key: _formKey,
        onChanged: () {
          if (_isButtonEnabled == isAnyFieldEmpty()) {
            setState(() => _isButtonEnabled = !_isButtonEnabled);
          }
        },
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
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(
                        Icons.email,
                      ),
                    ),
                    onEditingComplete: () => _passwordFocusNode.requestFocus(),
                    validator: (value) {
                      if (_emailErrorMessage != null) {
                        return _emailErrorMessage;
                      } else if (value == '') {
                        return 'Email can\'t be empty';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    focusNode: _passwordFocusNode,
                    obscureText: !_passwordVisibility,
                    controller: _passwordTextEditingController,
                    autocorrect: false,
                    textInputAction: widget.isRegisteredUser
                        ? TextInputAction.done
                        : TextInputAction.next,
                    decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(
                          Icons.lock,
                        ),
                        suffixIcon: IconButton(
                          icon: _passwordVisibility
                              ? const Icon(Icons.visibility_off)
                              : const Icon(Icons.visibility),
                          onPressed: () => setState(
                              () => _passwordVisibility = !_passwordVisibility),
                        )),
                    validator: (value) {
                      if (_passwordErrorMessage != null) {
                        return _passwordErrorMessage;
                      } else if (value == '') {
                        return 'Password can\'t be empty. Please fill password field';
                      }
                      return null;
                    },
                    onEditingComplete: widget.isRegisteredUser
                        ? null
                        : () => _confirmPasswordFocusNode.requestFocus(),
                  ),
                  widget.isRegisteredUser
                      ? Align(
                          alignment: Alignment.topLeft,
                          child: TextButton(
                            // <-- TextButton
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ResetPassScreen()));
                            },
                            style: TextButton.styleFrom(
                              textStyle: const TextStyle(),
                            ),
                            child: Text(
                              'Forgot your password?',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : null),
                            ),
                          ),
                        )
                      : Container(),
                  Visibility(
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    visible: !widget.isRegisteredUser,
                    child: TextFormField(
                      focusNode: _confirmPasswordFocusNode,
                      obscureText: !_confirmPasswordVisibility,
                      controller: _confirmPasswordTextEditingController,
                      autocorrect: false,
                      decoration: InputDecoration(
                          labelText: 'Confirm password',
                          prefixIcon: const Icon(
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
                      validator: widget.isRegisteredUser
                          ? null
                          : (value) {
                              if (_confirmPasswordErrorMessage != null) {
                                return _confirmPasswordErrorMessage;
                              } else if (value == '') {
                                return 'Confirm password can\'t be empty. Please fill password field';
                              } else if (_passwordTextEditingController.text !=
                                  _confirmPasswordTextEditingController.text) {
                                return 'The passwords do not match';
                              }
                              return null;
                            },
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: !_isButtonEnabled ? null : onPressedSign,
                child: Text(
                  widget.isRegisteredUser ? 'Sign in' : 'Sign up',
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
        prefixIcon: const Icon(
          Icons.lock,
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.visibility),
          onPressed: () => setState(() => showPassword = !showPassword),
        ));
  }

  bool isAnyFieldEmpty() {
    return _emailTextEditingController.text.isEmpty ||
        _passwordTextEditingController.text.isEmpty ||
        (_confirmPasswordTextEditingController.text.isEmpty &&
            !widget.isRegisteredUser);
  }

  Future onPressedSign() async {
    final email = _emailTextEditingController.text;
    final password = _passwordTextEditingController.text;

    _emailErrorMessage = null;
    _passwordErrorMessage = null;
    _confirmPasswordErrorMessage = null;

    if (_formKey.currentState!.validate() &&
        (widget.isRegisteredUser ||
            _passwordTextEditingController.text ==
                _confirmPasswordTextEditingController.text)) {
      try {
        FirebaseEmailAuthentication firebaseEmailAuthentication =
            FirebaseEmailAuthentication.instance();
        firebaseEmailAuthentication.initInstance(
            email: email,
            password: password,
            isRegisteredUser: widget.isRegisteredUser);

        final firebaseAuthenticationNotifier =
            Provider.of<FirebaseAuthenticationNotifier>(context, listen: false);

        firebaseAuthenticationNotifier
            .setFirebaseAuthentication(firebaseEmailAuthentication);

        await firebaseAuthenticationNotifier.signIn();
        User? curUser = FirebaseAuth.instance.currentUser;
        if (curUser != null && !curUser.emailVerified) {
          await showAlertDialog(context);
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (BuildContext context) => const Pickeep()),
              (route) => false);
        }
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
