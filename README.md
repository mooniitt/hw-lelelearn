# LeLeLearn - 乐乐学

## 简介

LeLeLearn 是一款基于 OpenHarmony NEXT 版本开发的入门级 ArkTS 应用。它旨在为初学者提供一个简单明了的示例，展示如何使用 ArkTS 构建一个功能性的 HarmonyOS 应用。

该应用的主要功能是展示一个课程列表，并允许用户点击列表项查看课程详情。

## 项目结构

```
/lelelearn
├── entry/src/main/ets/             # ArkTS 源码
│   ├── entryability/               # 应用入口
│   ├── model/                      # 数据模型与服务
│   │   ├── Lesson.ets
│   │   ├── LessonService.ets
│   │   └── ProgressService.ets
│   ├── pages/                      # UI 页面
│   │   ├── Index.ets               # 首页
│   │   └── LessonPage.ets          # 课程详情页
├── entry/src/main/resources/       # 应用资源
│   ├── base/
│   └── rawfile/
│       └── lessons.json            # 课程数据
└── hvigorfile.ts                   # 项目构建脚本
```

## 主要技术栈

*   **HarmonyOS SDK**: OpenHarmony NEXT
*   **Language**: ArkTS
*   **UI Framework**: ArkUI
*   **Build Tool**: HVigor

## 如何运行

1.  确保您已安装最新版本的 [DevEco Studio](https://developer.harmonyos.com/cn/develop/deveco-studio/)。
2.  在 DevEco Studio 中选择 "File" -> "Open" -> 选择 `lelelearn` 项目根目录。
3.  等待项目同步和构建完成。
4.  在右上角的设备管理器中选择一个模拟器或连接一个真机。
5.  点击 "Run" -> "entry" 即可在目标设备上运行应用。

## 待办事项

- [ ] 增加单元测试
- [ ] 完善课程进度跟踪功能
- [ ] 美化 UI 界面