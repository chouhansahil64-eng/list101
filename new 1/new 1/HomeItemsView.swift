//
//  HomeItemsView.swift
//  new 1
//
//  Created by Sahil Chouhan on 12/11/25.
//

import SwiftUI

struct HomeItemsView: View {
    let items: [String]
    let onAddToCart: (_ name: String, _ quantity: Int) -> Void

    @State private var selectedItem: String?
    @State private var quantity: Int = 1
    @State private var showQuantitySheet: Bool = false

    private let columns = [
        GridItem(.adaptive(minimum: 110), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(items, id: \.self) { item in
                    Button {
                        selectedItem = item
                        quantity = 1
                        showQuantitySheet = true
                    } label: {
                        VStack(spacing: 8) {
                            Text(icon(for: item))
                                .font(.system(size: 36))
                            Text(item)
                                .font(.headline)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.primary)
                                .lineLimit(2)
                                .minimumScaleFactor(0.8)
                        }
                        .frame(maxWidth: .infinity, minHeight: 100)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.separator), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Add \(item)")
                }
            }
            .padding()
        }
        .background(Color.appBackground)
        .navigationTitle("Home Items")
        .sheet(isPresented: $showQuantitySheet) {
            QuantitySheet(
                fruitName: selectedItem ?? "",
                quantity: $quantity,
                onCancel: { showQuantitySheet = false },
                onAdd: {
                    if let name = selectedItem {
                        onAddToCart(name, quantity)
                    }
                    showQuantitySheet = false
                }
            )
            .presentationDetents([PresentationDetent.height(260), .medium])
        }
    }

    // Provide an emoji/icon hint for common home items
    private func icon(for name: String) -> String {
        let n = name.lowercased()
        if n.contains("clock") { return "⏰" }
        if n.contains("chair") { return "🪑" }
        if n.contains("table") || n.contains("desk") { return "🛋️" }
        if n.contains("sofa") { return "🛋️" }
        if n.contains("lamp") { return "🛋️" } // limited emoji; reuse
        if n.contains("bookshelf") { return "📚" }
        if n.contains("rug") || n.contains("mat") { return "🧶" }
        if n.contains("curtain") { return "🪟" }
        if n.contains("mirror") { return "🪞" }
        if n.contains("vase") { return "🏺" }
        if n.contains("plant") { return "🪴" }
        if n.contains("cushion") || n.contains("pillow") { return "🛏️" }
        if n.contains("blanket") { return "🧣" }
        if n.contains("trash") || n.contains("bin") { return "🗑️" }
        if n.contains("laundry") { return "🧺" }
        if n.contains("coat") || n.contains("hanger") { return "🧥" }
        if n.contains("shoe") { return "👟" }
        if n.contains("art") || n.contains("frame") { return "🖼️" }
        if n.contains("candle") { return "🕯️" }
        if n.contains("towel") { return "🧻" }
        if n.contains("soap") { return "🧼" }
        if n.contains("toothbrush") { return "🪥" }
        if n.contains("shower") { return "🚿" }
        if n.contains("box") || n.contains("storage") { return "📦" }
        if n.contains("doormat") { return "🚪" }
        if n.contains("cutlery") || n.contains("knife") { return "🍴" }
        if n.contains("plate") || n.contains("bowl") { return "🍽️" }
        if n.contains("mug") || n.contains("glass") { return "🥛" }
        if n.contains("kettle") { return "☕️" }
        if n.contains("toaster") { return "🍞" }
        if n.contains("blender") { return "🥤" }
        if n.contains("microwave") { return "🍲" }
        if n.contains("spice rack") { return "🧂" }
        if n.contains("chopping board") { return "🔪" }
        if n.contains("dish rack") { return "🧼" }
        if n.contains("oven mitt") { return "🧤" }
        if n.contains("apron") { return "👚" }
        if n.contains("broom") { return "🧹" }
        if n.contains("dustpan") { return "🧹" }
        if n.contains("mop") { return "🧹" }
        if n.contains("bucket") { return "🪣" }
        if n.contains("tool") { return "🧰" }
        return "🏠"
    }
}

#Preview {
    NavigationStack {
        HomeItemsView(
            items: [
                "Clock", "Chair", "Table", "Sofa", "Lamp", "Bookshelf", "Rug", "Curtains",
                "Mirror", "Vase", "Picture Frame", "Plant Pot", "Cushion", "Blanket", "Desk",
                "Office Chair", "Trash Can", "Laundry Basket", "Coat Rack", "Shoe Rack",
                "Wall Art", "Candle", "Towel", "Soap Dispenser", "Toothbrush Holder",
                "Shower Curtain", "Bath Mat", "Storage Box", "Hanger", "Doormat",
                "Cutlery Set", "Plates", "Bowls", "Mugs", "Glasses", "Kettle",
                "Toaster", "Blender", "Microwave Cover", "Spice Rack",
                "Knife Set", "Chopping Board", "Dish Rack", "Oven Mitts", "Apron",
                "Broom", "Dustpan", "Mop", "Bucket", "Tool Kit"
            ],
            onAddToCart: { _, _ in }
        )
    }
}
