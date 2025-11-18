import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_tem/services/index.dart';
import 'package:flutter_tem/utils/storage/index.dart';
import 'package:get/get.dart';
import '../../routers/app_routes.dart';

class GuideView extends StatelessWidget {
  const GuideView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: Text('进入 App${dotenv.env['API_URL']}'),
          onPressed: () async {
            Global.init();
            final token = await Storage.getString('token');

            if (token != null) {
              Get.offAllNamed(AppRoutes.index);
            } else {
              Get.offAllNamed(AppRoutes.login);
            }
          },
        ),
      ),
    );
  }
}
