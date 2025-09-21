# LiveEventsStreaming

## 架構說明文件

### 🔹 架構層級
專案採用 **Clean Architecture + MVVM + Combine**：

- **Domain Layer**
  - Entities
  - Use Cases
  - Repository Interfaces
- **Data Layer**
  - Repository Implementations
  - API / Network
- **Presentation Layer (MVVM)**
  - ViewModels
  - Views

---

### 🔹 第三方套件管理
本專案使用 **CocoaPods** 作為第三方套件管理工具，方便整合常用框架與維護依賴版本。 

---

### 🔹 Swift Concurrency / Combine 使用場景
- 畫面資料綁定  
- API 請求  
- Socket 連線  
- 非同步任務處理  

👉 所有以上場景皆使用 **Combine** 實作。

---

### 🔹 資料存取 Thread-Safe 策略
- **ViewModel 層級控管執行緒切換**：  
  - 對外暴露 **Main Thread**（UI 安全）  
  - 對內運行於 **Background Thread**（避免阻塞 UI）  

---

### 🔹 UI 與 ViewModel 資料綁定
- 採用 **Combine 的 Publisher/Subscriber 機制**  
- **ViewModel**：
  - 定義 **Input** 與 **Output** 結構  
  - 提供 `transform` 方法，統一處理資料流轉換與事件邏輯  

---

### 🔹 操作影片
[▶️ 點此觀看操作示範](https://drive.google.com/file/d/1d-IYP2CvObEbAsGehbUsELlVnVPyUSv-/view?usp=sharing)
