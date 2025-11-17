//
//  CleanersView.swift
//  new 1
//
//  Created by Sahil Chouhan on 12/11/25.
//

import SwiftUI

struct CleanersView: View {
    let cleaners: [String]
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
                ForEach(cleaners, id: \.self) { item in
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
        .navigationTitle("Cleaning Items")
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

    private func icon(for name: String) -> String {
        let n = name.lowercased()
        if n.contains("dish") { return "🍽️" }
        if n.contains("laundry") || n.contains("detergent") { return "👕" }
        if n.contains("bleach") { return "🧪" }
        if n.contains("glass") || n.contains("window") { return "🪟" }
        if n.contains("floor") || n.contains("mop") { return "🧹" }
        if n.contains("bath") || n.contains("toilet") { return "🚽" }
        if n.contains("tile") { return "🧱" }
        if n.contains("disinfect") || n.contains("sanit") { return "🧴" }
        if n.contains("air") || n.contains("fresh") { return "🌬️" }
        if n.contains("carpet") { return "🧶" }
        if n.contains("polish") { return "✨" }
        if n.contains("wipe") { return "🧻" }
        if n.contains("paper") { return "🧻" }
        if n.contains("bag") || n.contains("garbage") { return "🗑️" }
        if n.contains("sponge") || n.contains("scrub") { return "🧽" }
        if n.contains("brush") { return "🪥" }
        if n.contains("duster") { return "🧹" }
        if n.contains("cloth") || n.contains("microfiber") { return "🧼" }
        if n.contains("glove") { return "🧤" }
        if n.contains("drain") || n.contains("descaler") { return "🚿" }
        return "🧼"
    }
}

#Preview {
    NavigationStack {
        CleanersView(
            cleaners: [
                "Dish Soap", "Laundry Detergent", "Fabric Softener", "Bleach", "Glass Cleaner",
                "All-Purpose Cleaner", "Floor Cleaner", "Bathroom Cleaner", "Toilet Cleaner",
                "Tile Cleaner", "Surface Disinfectant", "Hand Wash", "Hand Sanitizer",
                "Air Freshener", "Room Spray", "Carpet Cleaner", "Stain Remover", "Lime Scale Remover",
                "Oven Cleaner", "Degreaser", "Wood Polish", "Metal Polish", "Leather Cleaner",
                "Upholstery Cleaner", "Dishwasher Tablets", "Rinse Aid", "Salt for Dishwasher",
                "Detergent Pods", "Detergent Powder", "Detergent Liquid", "Fabric Refresher",
                "Mop Refill", "Floor Wipes", "Disinfectant Wipes", "Paper Towels", "Toilet Paper",
                "Garbage Bags", "Sponge", "Scrub Pad", "Steel Wool", "Brush Set", "Toilet Brush",
                "Squeegee", "Duster", "Microfiber Cloth", "Gloves", "Bucket Cleaner", "Descaler",
                "Drain Cleaner"
            ],
            onAddToCart: { _, _ in }
        )
    }
}
