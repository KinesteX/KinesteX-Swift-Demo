### Minimum Device Requirements: 
- iOS: iOS 14.0 or higher

## Configuration

### 1. Add Permissions


#### Info.plist

Add the following keys for camera usage:

```xml
<key>NSCameraUsageDescription</key>
<string>Please grant access to camera to start AI Workout</string>
```

### 2. Install KinesteX SDK framework

Add the framework as a package dependency with the following URL:

```xml
https://github.com/KinesteX/KinesteX-SDK-Swift.git
```

### 3. Setup recommendations
Initialize Variables 
 ```swift
   @State var showKinesteX = false // Controls KinesteX SDK visibility
   @State var isLoading = false    // Optional: Controls custom loading screen

   let apiKey = apikey // Your KinesteX API key
   let company = "yourcompanyname" // Your company identifier
   let userId = userId // Unique identifier for user tracking and progress. Must be unique per user, can be any string value


   // Optional: UserDetails to customize workout intensity
   let user = UserDetails(age: 20, height: 170, weight: 70, gender: .Male, lifestyle: .Active)
 ```
# Next Steps
### **[> Available Integration Options](integration/overview.md)**


