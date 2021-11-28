import 'dart:convert';
import 'dart:io';

import 'package:cache_manager/cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:scarvs/app/constants/app.keys.dart';
import 'package:scarvs/app/routes/app.routes.dart';
import 'package:scarvs/core/api/user.api.dart';
import 'package:scarvs/core/models/user.model.dart';
import 'package:scarvs/core/utils/snackbar.util.dart';

class UserNotifier with ChangeNotifier {
  final UserAPI _userAPI = UserAPI();

  String? userEmail;
  String? get getUserEmail => userEmail;

  String? userName;
  String? get getUserName => userName;

  Future getUserData({
    required String token,
    required BuildContext context,
  }) async {
    try {
      var userData = await _userAPI.getUserData(token: token);
      var response = UserModel.fromJson(jsonDecode(userData));

      final _data = response.data;
      final _received = response.received;

      if (!_received) {
        Navigator.of(context)
            .pushReplacementNamed(AppRouter.loginRoute)
            .whenComplete(
              () => {
                DeleteCache.deleteKey(AppKeys.userData).whenComplete(
                  () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackUtil.stylishSnackBar(
                        text: 'Oops Session Timeout', context: context),
                  ),
                )
              },
            );
      } else {
        userEmail = _data.email;
        userName = _data.username;
        notifyListeners();
      }
    } on SocketException catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackUtil.stylishSnackBar(
            text: 'Oops No You Need A Good Internet Connection',
            context: context),
      );
    } catch (e) {
      print(e);
    }
  }
}