import 'package:flutter_tem/api/http.dart';

const login = '/pklApi/public/user/app/login';

Future<dynamic> loginApi(dynamic params) async {
  return await Api.instance.post(login, data: params);
}

Future<dynamic> getUserDetailByUserIdApi(dynamic params) async {
  return await Api.instance
      .post('/pklApi/private/user/getUserDetailByUserId', data: params);
}
