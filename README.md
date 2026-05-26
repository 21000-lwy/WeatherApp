# WeatherApp — 鸿蒙天气助手

> 一款基于 **HarmonyOS NEXT / API 12+** 开发的轻量级天气查询应用，使用 ArkTS 语言与声明式 UI 构建。支持实时天气获取、城市搜索、历史记录本地持久化与详情展示。

---

## 📱 功能特性

| 功能 | 说明 |
|------|------|
| **实时天气** | 对接高德地图天气 API，获取当前温度、天气状况、风向风力、湿度 |
| **城市切换** | 支持手动输入城市名称，或一键选择热门城市（北京、上海、广州等） |
| **天气详情** | 独立详情页展示温度/湿度进度条、天气图标、出行建议 |
| **查询历史** | 自动保存查询记录到本地 RDB 数据库，支持删除与快速回切 |
| **状态管理** | 全局单例 `WeatherStore` + 监听者模式，跨页面数据同步 |
| **请求防重** | 基于 `fetchingPromise` 与 `fetchingCity` 双重校验，防止快速切换导致的数据错乱 |
| **错误处理** | 网络超时、API 异常、空数据等场景均有友好提示与重试机制 |

---

## 🛠 技术栈

- **开发语言**：ArkTS（TypeScript 超集）
- **目标平台**：HarmonyOS Phone
- **SDK 版本**：API 12 / compatibleSdkVersion `6.0.1(21)`
- **构建工具**：Hvigor
- **网络请求**：`@ohos.net.http`
- **本地存储**：`@ohos.data.relationalStore`（SQLite）
- **状态管理**：单例类 + `@State` / `@Prop` 响应式绑定
- **页面路由**：`@ohos.router`

---

## 📁 项目结构

```
WeatherApp/
├── AppScope/                    # 应用级配置
├── entry/                       # 主模块（Entry HAP）
│   ├── src/main/
│   │   ├── ets/
│   │   │   ├── entryability/
│   │   │   │   └── EntryAbility.ets      # 入口 Ability
│   │   │   ├── model/
│   │   │   │   ├── WeatherModel.ets        # 数据类型定义
│   │   │   │   ├── DatabaseModel.ets       # RDB 数据库操作
│   │   │   │   └── WeatherStore.ets        # 全局状态管理（单例）
│   │   │   ├── service/
│   │   │   │   └── WebService.ets          # 高德 API 网络封装
│   │   │   └── pages/
│   │   │       ├── Index.ets               # 首页（天气卡片 + 历史记录）
│   │   │       ├── CitySelectPage.ets      # 城市搜索页
│   │   │       ├── WeatherDetailPage.ets   # 天气详情页
│   │   │       └── components/
│   │   │           ├── TopBar.ets          # 顶部渐变标题栏
│   │   │           ├── WeatherCard.ets     # 主天气信息卡片
│   │   │           ├── HistoryList.ets     # 历史查询列表
│   │   │           └── LoadingError.ets    # 加载/错误状态组件
│   │   └── resources/
│   │       ├── rawfile/
│   │       │   └── app_config.json         # 高德 API 配置（需自行填写）
│   │       └── ...
│   └── ...
├── build-profile.json5          # 构建配置
├── oh-package.json5             # 依赖配置
└── hvigorfile.ts                # Hvigor 构建脚本
```

---

## 🚀 快速开始

### 1. 克隆项目

```bash
git clone https://github.com/21000-lwy/WeatherApp.git
```

### 2. 配置高德 API Key

在 `entry/src/main/resources/rawfile/app_config.json` 中填入你的高德 Web 服务 Key：

```json
{
  "amap": {
    "weatherKey": "你的高德Key",
    "baseUrl": "https://restapi.amap.com/v3/weather/weatherInfo"
  }
}
```

> 申请地址：[高德开放平台](https://lbs.amap.com/) → 控制台 → 应用管理 → 添加 Key（Web 服务类型）。

### 3. 编译运行

使用 **DevEco Studio** 打开项目，连接鸿蒙真机或模拟器，点击运行即可。

---

## 🔐 权限声明

应用在 `module.json5` 中已申请网络权限：

```json
{
  "name": "ohos.permission.INTERNET",
  "usedScene": {
    "abilities": ["EntryAbility"],
    "when": "always"
  }
}
```

---

## 🧩 核心设计亮点

### 1. 防重复请求机制（Index.ets）

首页通过 `fetchingPromise` 与 `fetchingCity` 两个私有变量，实现以下策略：
- **同城市并发**：直接返回正在进行的 Promise，避免重复调用。
- **跨城市切换**：等待上一个请求完成后再发起新请求，防止竞态条件。
- **城市校验**：请求完成前若城市已变更，则丢弃旧数据，确保 UI 始终展示用户最后选择的城市。

### 2. 全局状态管理（WeatherStore.ets）

采用单例模式 + 监听器数组，实现跨页面数据同步：
- `updateWeather()` 更新后会遍历通知所有监听者。
- `Index` 页面订阅 Store，当 `CitySelectPage` 查询到新天气后回退，首页自动刷新。

### 3. 本地数据库（DatabaseModel.ets）

基于鸿蒙 `relationalStore` 实现：
- 表结构：`history_city(id, cityName, queryTime)`
- 插入前先去重（删除该城市旧记录），保证历史列表中同一城市仅保留最新一条。
- 查询结果按 `id` 降序排列，即最近查询在前。

### 4. 天气图标映射

使用 Unicode Emoji 作为轻量级天气图标，根据关键字匹配：

| 天气关键字 | 图标 |
|-----------|------|
| 晴 | ☀️ |
| 多云 | ⛅ |
| 阴 | ☁️ |
| 雨 | 🌧️ |
| 雪 | ❄️ |
| 雷 | ⛈️ |
| 雾 | 🌫️ |
| 其他 | 🌈 |

---

## ⚠️ 注意事项

1. **API Key 安全**：`app_config.json` 中的 Key 为客户端明文存储，仅供学习演示。生产环境建议通过后端代理或服务器下发。
2. **城市名称**：高德 API 要求输入完整城市名称（如“北京”），不支持拼音或简称。
3. **网络环境**：首次启动需确保设备联网，否则会在 `LoadingError` 组件中提示重试。
