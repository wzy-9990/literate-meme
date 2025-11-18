import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class EnvConfig {
  static Future<void> load() async {
    const env = String.fromEnvironment('ENV', defaultValue: 'development');
    const envFile = '.env.$env';

    try {
      await dotenv.load(fileName: envFile);
      debugPrint('✅ 环境加载成功: $envFile');
    } catch (e) {
      debugPrint('❌ 环境加载失败: $e');
      rethrow;
    }
  }
}