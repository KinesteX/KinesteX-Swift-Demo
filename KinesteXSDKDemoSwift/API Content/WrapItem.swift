import SwiftUI

struct WrapView<Item: Hashable, Content: View>: View {
    let items: [Item]
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Item) -> Content
    
    init(items: [Item], spacing: CGFloat = 8, alignment: HorizontalAlignment = .leading, @ViewBuilder content: @escaping (Item) -> Content) {
        self.items = items
        self.spacing = spacing
        self.alignment = alignment
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
        .frame(height: calculateHeight(availableWidth: UIScreen.main.bounds.width))
    }
    
    func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        return ZStack(alignment: .topLeading) {
            ForEach(items, id: \.self) { item in
                content(item)
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { dimension in
                        if abs(width - dimension.width) > geometry.size.width {
                            width = 0
                            height -= (dimension.height + spacing)
                        }
                        let result = width
                        if item == items.last {
                            width = 0 // last item
                        } else {
                            width -= (dimension.width + spacing)
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { _ in
                        let result = height
                        return result
                    })
            }
        }
    }
    
    func calculateHeight(availableWidth: CGFloat) -> CGFloat {
        var width = CGFloat.zero
        var height = CGFloat.zero
        let maxWidth = availableWidth
        
        for item in items {
            // Assuming a fixed height for simplicity
            let itemWidth = CGFloat(100) // Approximate width
            if width + itemWidth > maxWidth {
                width = 0
                height += 20 // Fixed height
            }
            width += itemWidth + spacing
        }
        
        return height + 20
    }
}

