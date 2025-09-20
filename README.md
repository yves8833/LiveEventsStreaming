# LiveEventsStreaming

## 架構說明文件

### 架構
使用 Clean Architecture + MVVM + Combine 框架

* Domain Layer = Entities + Use Cases + Repositories Interfaces
* Data Repositories Layer = Repositories Implementations + API (Network)
* Presentation Layer (MVVM) = ViewModels + Views

### 簡要說明

#### Swift Concurrency / Combine 使用場景
畫面資料綁定、api請求、socket 連線、非同步任務等皆使用 Combine 實作

#### 如何確保資料存取 thread-safe？
在 viewModel 統一控管線層切換，對外暴露 main thread，對內部使用 background thread

#### UI 與 ViewModel 資料綁定方式

使用 Combine 的 Publisher/Subscriber 機制進行資料綁定
ViewModel 定義 Input 與 Output 結構，並包含 transform 方法來處理資料流轉換



