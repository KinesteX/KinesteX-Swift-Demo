## Custom Initial Loading Animation

```swift
 // OPTIONAL: Display loading screen during view initialization
    KinesteXAIFramework.createMainView(...)
    .overlay(
        Group {
            if showAnimation {
                Text("Aifying workouts...")
                    .foregroundColor(.black)
                    .font(.caption)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)
                    .scaleEffect(showAnimation ? 1 : 3)
                    .opacity(showAnimation ? 1 : 0)
                    .animation(.easeInOut(duration: 1.5), value: showAnimation)
            }
        }
    )
    .onChange(of: isLoading) { newValue in
        withAnimation(.easeInOut(duration: 2.5)) {
            showAnimation = !newValue
        }
    }

```