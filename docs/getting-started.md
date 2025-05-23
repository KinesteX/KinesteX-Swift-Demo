### Minimum Device Requirements: 
- iOS: iOS 14.0 or higher

## Configuration

### 1. Add Permissions


#### Info.plist

Add the following keys for camera usage:

```xml
<key>NSCameraUsageDescription</key>
<string>Please grant access to camera to start AI Workout</string>
<key>NSMotionUsageDescription</key>
<string>We need access to your device's motion sensors to properly position your phone for the workout</string>
```

**If you do not have Info.plist:**
Open project in Xcode > click project name > select target > Info tab > Custom Application Target Properties > add "Privacy - Camera Usage Description" key with message requesting camera permission.


### 2. Install KinesteX AI Kit

Add the framework as a package dependency with the following URL:

```xml
https://github.com/KinesteX/KinesteX-AI-Kit.git
```
Now import it: 
```
import KinesteXAIKit
```
### 3. Setup recommendations
Initialize Variables 
 ```swift
   @State var showKinesteX = false // Controls KinesteX SDK visibility
   @State var isLoading = false    // Optional: Controls custom loading screen
    
    // Initialize KinesteXAIKit with your kinesteX API key, your company identifier, and unique identifier for user tracking and progress. Must be unique per user, can be any string value
    let kinestex = KinesteXAIKit(apiKey: "YOUR_API_KEY", companyName: "YOUR_COMPANY_NAME", userId: "YOUR_USER_ID")

   // Optional: UserDetails to customize workout intensity
   let user = UserDetails(age: 20, height: 170, weight: 70, gender: .Male, lifestyle: .Active)
 ```
# Next Steps
### **[> Available Integration Options](integration/overview.md)**


