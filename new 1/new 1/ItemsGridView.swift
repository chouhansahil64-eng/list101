import SwiftUI

struct ItemsGridView: View {
    let items: [GroceryItem]
    let onAddToCart: (_ item: GroceryItem) -> Void

    @State private var searchText: String = ""
    @State private var selectedItem: GroceryItem?
    @State private var quantity: Int = 1
    @State private var showQuantitySheet: Bool = false

    private let columns = [
        GridItem(.adaptive(minimum: 120), spacing: 12)
    ]

    private var filteredItems: [GroceryItem] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return items }
        return items.filter { $0.name.localizedCaseInsensitiveContains(trimmed) }
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(filteredItems) { item in
                    Button {
                        selectedItem = item
                        quantity = 1
                        showQuantitySheet = true
                    } label: {
                        VStack(spacing: 8) {
                            Text(icon(for: item.name))
                                .font(.system(size: 36))
                            Text(item.name)
                                .font(.headline)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.primary)
                                .lineLimit(2)
                                .minimumScaleFactor(0.8)
                        }
                        .frame(maxWidth: .infinity, minHeight: 110)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.separator), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Add \(item.name)")
                }
            }
            .padding()
        }
        .navigationTitle("All Items")
        .searchable(text: $searchText, prompt: Text("Search items"))
        .sheet(isPresented: $showQuantitySheet) {
            QuantitySheet(
                fruitName: selectedItem?.name ?? "",
                quantity: $quantity,
                onCancel: { showQuantitySheet = false },
                onAdd: {
                    if var base = selectedItem {
                        base.quantity = quantity
                        onAddToCart(base)
                    }
                    showQuantitySheet = false
                }
            )
            .presentationDetents([.height(260), .medium])
        }
    }

    // Simple icon hints based on name keywords
    private func icon(for name: String) -> String {
        let n = name.lowercased()
        if n.contains("apple") { return "🍎" }
        if n.contains("banana") { return "🍌" }
        if n.contains("milk") { return "🥛" }
        if n.contains("bread") { return "🍞" }
        if n.contains("clock") { return "⏰" }
        if n.contains("chair") { return "🪑" }
        if n.contains("table") { return "🛋️" }
        if n.contains("towel") { return "🧻" }
        if n.contains("toilet") || n.contains("paper") { return "🧻" }
        if n.contains("soap") { return "🧼" }
        if n.contains("rice") { return "🍚" }
        if n.contains("cheese") { return "🧀" }
        if n.contains("egg") { return "🥚" }
        if n.contains("tomato") { return "🍅" }
        if n.contains("onion") { return "🧅" }
        if n.contains("yogurt") { return "🥛" }
        return "🛒"
    }
}
