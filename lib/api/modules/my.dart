import 'package:flutter_tem/api/http.dart';

const getUserInfo = '/pklApi/public/user/getUserInfo';

Future<dynamic> getUserInfoApi({bool showAuthDialogOn401 = true}) async {
  return await Api.instance
      .get(getUserInfo, showAuthDialogOn401: showAuthDialogOn401);
}

const updateUserInfo = '/pklApi/public/user/updateUserInfo';

Future<dynamic> updateUserInfoApi(dynamic params,
    {bool showAuthDialogOn401 = true}) async {
  return await Api.instance.post(
    updateUserInfo,
    data: params,
    showAuthDialogOn401: showAuthDialogOn401,
  );
}

const listPageUserByOrganizationId =
    '/pklApi/private/organization/listPageUserByOrganizationId';

Future<dynamic> listPageUserByOrganizationIdApi(
  dynamic params,
) async {
  return await Api.instance.post(
    listPageUserByOrganizationId,
    data: params,
  );
}

Future<dynamic> listPageUserByOrganizationIdApi222(
  dynamic params,
) async {
  return await Api.instance.post(
    listPageUserByOrganizationId,
    data: params,
    showAuthDialogOn401: false,
  );
}
