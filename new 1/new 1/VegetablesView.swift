//
//  VegetablesView.swift
//  new 1
//
//  Created by Sahil Chouhan on 12/11/25.
//

import SwiftUI

struct VegetablesView: View {
    let vegetables: [String]
    let onAddToCart: (_ name: String, _ quantity: Int) -> Void

    @State private var selectedVegetable: String?
    @State private var quantity: Int = 1
    @State private var showQuantitySheet: Bool = false

    private let columns = [
        GridItem(.adaptive(minimum: 110), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(vegetables, id: \.self) { veg in
                    Button {
                        selectedVegetable = veg
                        quantity = 1
                        showQuantitySheet = true
                    } label: {
                        VStack(spacing: 8) {
                            Text(emoji(for: veg))
                                .font(.system(size: 36))
                            Text(veg)
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
                    .accessibilityLabel("Add \(veg)")
                }
            }
            .padding()
        }
        .background(Color.appBackground)
        .navigationTitle("Vegetables")
        .sheet(isPresented: $showQuantitySheet) {
            QuantitySheet(
                fruitName: selectedVegetable ?? "",
                quantity: $quantity,
                onCancel: { showQuantitySheet = false },
                onAdd: {
                    if let name = selectedVegetable {
                        onAddToCart(name, quantity)
                    }
                    showQuantitySheet = false
                }
            )
            .presentationDetents([PresentationDetent.height(260), .medium])
        }
    }

    private func emoji(for name: String) -> String {
        let n = name.lowercased()
        if n.contains("tomato") { return "🍅" }
        if n.contains("potato") || n.contains("sweet") { return "🥔" }
        if n.contains("onion") { return "🧅" }
        if n.contains("garlic") { return "🧄" }
        if n.contains("carrot") { return "🥕" }
        if n.contains("cabbage") || n.contains("lettuce") || n.contains("greens") { return "🥬" }
        if n.contains("broccoli") { return "🥦" }
        if n.contains("cucumber") || n.contains("zucchini") { return "🥒" }
        if n.contains("pepper") || n.contains("chili") { return "🌶️" }
        if n.contains("corn") { return "🌽" }
        if n.contains("eggplant") { return "🍆" }
        if n.contains("mushroom") { return "🍄" }
        if n.contains("pumpkin") { return "🎃" }
        if n.contains("radish") { return "🧄" }
        if n.contains("beet") { return "🟣" }
        if n.contains("pea") || n.contains("beans") { return "🟢" }
        return "🥬"
    }
}

#Preview {
    NavigationStack {
        VegetablesView(
            vegetables: [
                "Tomato", "Potato", "Onion", "Garlic", "Ginger", "Carrot", "Cabbage", "Cauliflower",
                "Broccoli", "Spinach", "Lettuce", "Cucumber", "Bell Pepper", "Green Chili", "Peas",
                "Corn", "Eggplant", "Zucchini", "Pumpkin", "Radish", "Beetroot", "Okra", "Bitter Gourd",
                "Bottle Gourd", "Snake Gourd", "Drumstick", "Yam", "Sweet Potato", "Turnip", "Leek",
                "Celery", "Asparagus", "Artichoke", "Mushroom", "Spring Onion", "Scallion", "Chives",
                "Kale", "Swiss Chard", "Arugula", "Fenugreek Leaves", "Mustard Greens", "Dill",
                "Parsley", "Coriander Leaves", "Mint", "Curry Leaves", "Green Beans", "Cluster Beans",
                "Ridge Gourd", "Ivy Gourd"
            ],
            onAddToCart: { _, _ in }
        )
    }
}
