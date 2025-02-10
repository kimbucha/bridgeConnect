import SwiftUI
import BridgeConnectKit

struct CategoryScrollView: View {
    let selectedCategory: ResourceCategory?
    let onSelectCategory: (ResourceCategory?) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ResourceCategory.categories) { category in
                    CategoryButton(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation {
                            if selectedCategory == category {
                                onSelectCategory(nil)
                            } else {
                                onSelectCategory(category)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
}

struct CategoryButton: View {
    let category: ResourceCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : category.color)
                
                Text(category.title)
                    .font(.caption)
                    .bold()
                    .foregroundColor(isSelected ? .white : .primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 90, height: 90)
            .background(isSelected ? category.color : Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

#if DEBUG
struct CategoryScrollView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CategoryScrollView(
                selectedCategory: nil,
                onSelectCategory: { _ in }
            )
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Default")
            
            CategoryScrollView(
                selectedCategory: ResourceCategory.categories.first,
                onSelectCategory: { _ in }
            )
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Selected Category")
            
            CategoryScrollView(
                selectedCategory: nil,
                onSelectCategory: { _ in }
            )
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Dark Mode")
        }
    }
}
#endif
