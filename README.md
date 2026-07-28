# BleSdkDemo（iOS）

对标 Android 工程 `blesdk_android` 的 iOS Demo，基于华沃 `HwBluetoothSDK` + `WatchfaceSDK`（思澈推送）。

## 功能对照

| 功能 | 说明 |
|------|------|
| 扫描连接 | `scan` / `connectWithDevice` / `connectWithMac` |
| 绑定流程 | startBind → 时间/用户/单位/语言 → getDeviceInfo → endBind → 配对查询 |
| 解绑流程 | unbindDevice → disconnect → removeConnectionCache → 清本地 |
| 同步健康数据 | getActivityNum + activities / heartrates / sleeps |
| 目标 | getGoal / setGoal |
| 闹钟与提醒 | 闹钟 CRUD、久坐 / 喝水 / 洗手 |
| 通知 / 通讯录 | social apps、contacts |
| 音乐推送 | 杰理 `startMultipleFileTransfer` / 思澈 `setMusicFiles` |
| 相册推送 | 杰理 Photo 传输 / 思澈 `setPictures` |
| AGPS | 下载 5×`.pgl` + 16B trailer + `music/gps/agps/` zip + `syncZipFile(type:3, byteAlign:true)` |
| 音乐/相册 | `getBtConnectionState` 自动分流杰理 MFT / 思澈；失败回退；互斥与取消 |
| 同步健康 | 拉取后 `deleteActivities` / `deleteHeartrates` / `deleteSleeps` |
| 重连 | 对齐 HaWoFit `BleConnectManager`：绑定后断线立即重连，失败 0.5s 重试；后台不重连；回前台 / 蓝牙可用再连；手动断开关闭 |

## 依赖

- `HwBluetoothSDK`：本地路径 `../bluetooth-sdk-oc`（与 HaWoFit 同源）
- `WatchfaceSDK`：`Vendor/WatchfaceSDK`（从 HaWoFit Pods 拷贝，含 `SifliWatchfaceSDK`）

也可改成与 HaWoFit 相同的 git 源：

```ruby
pod 'HwBluetoothSDK', :git => 'http://192.168.12.244/ios/bluetoothsdk.git', :branch => 'develop'
pod 'WatchfaceSDK', :git => 'http://192.168.12.244/ios/watchfacesdk.git', :branch => 'main'
```

## 打开工程

```bash
cd /Users/sujiang/Projects/sdkdemo
pod install
open BleSdkDemo.xcworkspace
```

真机调试需在 Signing 里选择你的 Team。蓝牙相关能力请使用真机。

## 文档

- 本仓库根目录 `SDK_iOS.md`（从 `bluetooth-sdk-oc` 复制）
- Android 对照文档见 `blesdk_android/SDK_android.md`
