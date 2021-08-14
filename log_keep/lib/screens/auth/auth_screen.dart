import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:log_keep/app/app.dart';
import 'package:log_keep/repositories/auth_repository.dart';
import 'package:log_keep/repositories/settings_repository.dart';
import 'package:log_keep/screens/home/home_screen.dart';
import 'package:proviso/proviso.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  TextEditingController _loginController;
  TextEditingController _passwordController;
  bool _loginButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _loginController = TextEditingController();
    _loginController.text =
        getIt<SettingsRepository>().getString("last_login_name");
    _loginButtonEnabled = _loginController.text.isNotEmpty;
    _passwordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    var width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.center,
          child: new LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            var height = MediaQuery.of(context).size.height;
            return Container(
              width: kIsWeb ? min(500, width) : null,
              height: constraints.hasInfiniteHeight
                  ? height
                  : constraints.maxHeight,
              child: Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        icon: Icon(Icons.person),
                        labelText: 'Login',
                      ),
                      autocorrect: false,
                      obscureText: false,
                      textAlign: TextAlign.center,
                      controller: _loginController,
                      onChanged: (v) => {
                        setState(() {
                          _loginButtonEnabled = v.isNotEmpty && v.length >= 3;
                        })
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                        decoration: const InputDecoration(
                          icon: Icon(Icons.password),
                          labelText: 'Password',
                        ),
                        autocorrect: false,
                        obscureText: true,
                        textAlign: TextAlign.center,
                        controller: _passwordController),
                    Align(
                      alignment: Alignment.center,
                      child: ConditionWidget(
                          widget: _loginButton(context, textTheme, colorScheme),
                          condition: _loginButtonEnabled),
                    )
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    ));
  }

  IconButton _loginButton(
      BuildContext context, TextTheme textTheme, ColorScheme colorScheme) {
    return IconButton(
      icon: const Icon(Icons.login),
      tooltip: "Login",
      onPressed: () =>
          {_login(_loginController.text, _passwordController.text)},
    );
  }

  void _login(String login, String password) async {
    var result = await getIt<AuthRepository>().authenticate(login, password);

    if (result.isRight()) {
      final snackBar = SnackBar(content: Text('Auth failed'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      _navigateToDashboard(context);
    }
  }

  void _navigateToDashboard(BuildContext context) {
    getIt<SettingsRepository>()
        .putString("last_login_name", _loginController.text);
    HomeScreenNavigation.navigate(context);
  }
}
