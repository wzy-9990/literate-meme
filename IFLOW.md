# 项目概述

这是一个使用 Flutter 框架开发的移动应用项目，名为 `flutter_tem`。它采用了 GetX 状态管理方案，并集成了 Dio 网络请求库、屏幕适配方案 (flutter_screenutil)、环境变量管理 (flutter_dotenv) 和加载提示组件 (flutter_easyloading) 等常用功能。

## 核心技术栈

- **Flutter**: Google 的 UI 工具包，用于构建跨平台的移动应用。
- **Dart**: Flutter 的编程语言。
- **GetX**: 用于状态管理、路由管理和依赖注入的轻量级框架。
- **Dio**: 一个强大的 Dart HTTP 网络请求库，支持拦截器、全局配置、FormData、请求取消等。
- **flutter_screenutil**: 用于屏幕适配的库，确保 UI 在不同尺寸设备上的一致性。
- **flutter_dotenv**: 用于加载和管理环境变量的库。
- **flutter_easyloading**: 提供简单易用的加载提示 (Toast, Loading) 的库。
- **shared_preferences**: 用于在设备上持久化存储简单的键值对数据。

## 项目架构

项目遵循典型的 Flutter 项目结构，并结合 GetX 进行组织：

- `lib/main.dart`: 应用入口点，负责初始化和启动应用。
- `lib/routers/`: 路由配置，定义了应用的页面路径和对应的页面组件。
- `lib/page/`: 页面目录，包含所有页面的视图 (view)、逻辑 (logic) 和绑定 (binding)。
- `lib/api/`: 网络请求相关代码，包括 HTTP 客户端 (Dio) 的配置和 API 模块的定义。
- `lib/components/`: 可复用的 UI 组件。
- `lib/config/`: 应用配置，如环境变量加载、EasyLoading 配置等。
- `lib/services/`: 业务服务层，封装与业务逻辑相关的功能。
- `lib/styles/`: 全局样式定义。
- `lib/utils/`: 工具类和辅助函数，如存储 (`shared_preferences`)、字典、通用函数等。

## 环境配置

项目使用 `flutter_dotenv` 管理不同环境的配置。环境变量存储在 `.env.development`, `.env.test`, 和 `.env.production` 文件中。通过 `lib/config/env/index.dart` 在应用启动时加载对应的环境变量文件。当前开发环境 (`development`) 的 API 地址配置为 `https://test.ledug.cn/v2`。

## 网络请求

网络请求通过 `lib/api/http.dart` 中的 `ApiService` 类进行管理。该类使用 Dio 库，并配置了以下功能：

- 基础 URL 从环境变量中读取。
- 请求和响应拦截器用于日志打印、添加认证 Token、处理业务错误码和 HTTP 状态码。
- 封装了 `get` 和 `post` 方法，自动解析响应数据中的 `data` 字段。

## 路由管理

使用 GetX 进行路由管理。路由路径定义在 `lib/routers/app_routes.dart` 中，路由与页面的映射关系在 `lib/routers/app_pages.dart` 中配置。

## 构建和运行

### 前提条件

- 安装 Flutter SDK (版本 ^3.5.0)。
- 配置好 Flutter 开发环境。

### 运行项目

1. 获取依赖包:
   ```bash
   flutter pub get
   ```
2. 运行应用 (默认为开发环境):
   ```bash
   flutter run
   ```
   如果要指定环境，可以使用:
   ```bash
   flutter run --dart-define=ENV=production
   ```

### 构建项目

- 构建 APK:
  ```bash
  flutter build apk
  ```
- 构建 iOS (需要在 macOS 上):
  ```bash
  flutter build ios
  ```

## 开发约定

- **页面结构**: 每个页面通常由 `view.dart` (UI 视图), `logic.dart` (业务逻辑, 继承 `GetxController`) 和 `binding.dart` (依赖注入) 三个文件组成。
- **网络请求**: API 路径统一定义在 `lib/api/modules/` 目录下的对应模块文件中。
- **环境变量**: 不同环境的配置通过 `.env.*` 文件管理。
- **状态管理**: 优先使用 GetX 进行状态管理。
- **UI 组件**: 可复用的 UI 组件放在 `lib/components/` 目录下。