import '../../api/http.dart';

const getUserInfo = '/pklApi/public/user/getUserInfo';

Future<dynamic> getUserInfoApi() async {
  return await Api.instance.get(getUserInfo);
}

const updateUserInfo = '/pklApi/public/user/updateUserInfo';

Future<dynamic> updateUserInfoApi(dynamic params) async {
  return await Api.instance.post(updateUserInfo, data: params);
}