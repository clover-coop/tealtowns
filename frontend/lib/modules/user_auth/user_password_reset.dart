import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app_scaffold.dart';
import '../../common/socket_service.dart';
import './user_class.dart';
import '../../common/form_input/input_fields.dart';
import './current_user_state.dart';
import '../../routes.dart';

class UserPasswordResetComponent extends StatefulWidget {
  String resetKey;
  String email;
  UserPasswordResetComponent({this.resetKey = '', this.email = '' });

  @override
  _UserPasswordResetState createState() => _UserPasswordResetState();
}

class _UserPasswordResetState extends State<UserPasswordResetComponent> {
  List<String> _routeIds = [];
  SocketService _socketService = SocketService();
  InputFields _inputFields = InputFields();

  final _formKey = GlobalKey<FormState>();
  var formVals = {};
  bool _loading = false;
  String _message = '';

  @override
  void initState() {
    super.initState();

    _routeIds.add(_socketService.onRoute('passwordReset', callback: (String resString) {
      var res = jsonDecode(resString);
      var data = res['data'];
      if (data['valid'] == 1) {
        if (data.containsKey('user')) {
          var user = UserClass.fromJson(data['user']);
          if (user.id.length > 0) {
            Provider.of<CurrentUserState>(context, listen: false).setCurrentUser(user);
            String route = '/home';
            String redirectUrl = Provider.of<CurrentUserState>(context, listen: false).GetRedirectUrl();
            if (redirectUrl.length > 0) {
              route = redirectUrl;
            }
            context.go(route);
          } else {
            setState(() { _message = data['message'].length > 0 ? data['message'] : 'Please try again.'; });
          }
        } else {
          setState(() { _message = data['message'].length > 0 ? data['message'] : 'Please try again.'; });
        }
      } else {
        setState(() { _message = data['message'].length > 0 ? data['message'] : 'Please try again.'; });
      }
      setState(() { _loading = false; });
    }));

    if (widget.resetKey.length > 0) {
      formVals['passwordResetKey'] = widget.resetKey;
    }
    if (widget.email.length > 0) {
      formVals['email'] = widget.email;
    }
  }

  Widget _buildSubmit(BuildContext context) {
    if (_loading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: LinearProgressIndicator(
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() { _message = ''; });
          if (_formKey.currentState?.validate() == true) {
            setState(() { _loading = true; });
            _formKey.currentState?.save();
            _socketService.emit('passwordReset', formVals);
          } else {
            setState(() { _loading = false; });
          }
        },
        child: Text('Reset Password'),
      ),
    );
  }

  Widget _buildMessage(BuildContext context) {
    if (_message.length > 0) {
      return Text(_message);
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffoldComponent(
      listWrapper: true,
      width: 600,
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _inputFields.inputEmail(formVals, 'email'),
            _inputFields.inputText(formVals, 'passwordResetKey', minLen: 2, label: 'Reset Key'),
            _inputFields.inputPassword(formVals, 'password', minLen: 6, label: 'New Password'),
            _buildSubmit(context),
            _buildMessage(context),
          ]
        ),
      ),
    );
  }

  @override
  void dispose() {
    _socketService.offRouteIds(_routeIds);
    super.dispose();
  }
}