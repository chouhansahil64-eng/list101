//
//  SpicesView.swift
//  new 1
//
//  Created by Sahil Chouhan on 12/11/25.
//

import SwiftUI

struct SpicesView: View {
    let spices: [String]
    let onAddToCart: (_ name: String, _ quantity: Int) -> Void

    @State private var selectedSpice: String?
    @State private var quantity: Int = 1
    @State private var showQuantitySheet: Bool = false

    private let columns = [
        GridItem(.adaptive(minimum: 110), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(spices, id: \.self) { spice in
                    Button {
                        selectedSpice = spice
                        quantity = 1
                        showQuantitySheet = true
                    } label: {
                        VStack(spacing: 8) {
                            Text(spiceEmoji(for: spice))
                                .font(.system(size: 36))
                            Text(spice)
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
                    .accessibilityLabel("Add \(spice)")
                }
            }
            .padding()
        }
        .background(Color.appBackground)
        .navigationTitle("Spices")
        .sheet(isPresented: $showQuantitySheet) {
            QuantitySheet(
                fruitName: selectedSpice ?? "",
                quantity: $quantity,
                onCancel: { showQuantitySheet = false },
                onAdd: {
                    if let name = selectedSpice {
                        onAddToCart(name, quantity)
                    }
                    showQuantitySheet = false
                }
            )
            .presentationDetents([.height(260), .medium])
        }
    }

    private func spiceEmoji(for name: String) -> String {
        let n = name.lowercased()
        if n.contains("chili") || n.contains("pepper") { return "🌶️" }
        if n.contains("cinnamon") { return "🟤" }
        if n.contains("turmeric") || n.contains("saffron") { return "🟡" }
        if n.contains("coriander") || n.contains("cumin") || n.contains("caraway") { return "🟫" }
        if n.contains("ginger") { return "🟠" }
        if n.contains("garlic") { return "🧄" }
        if n.contains("onion") { return "🧅" }
        if n.contains("bay") { return "🍃" }
        if n.contains("cardamom") { return "🟢" }
        if n.contains("clove") { return "🟤" }
        return "🧂"
    }
}

#Preview {
    NavigationStack {
        SpicesView(
            spices: [
                "Black Pepper", "Cumin", "Coriander", "Turmeric", "Paprika", "Chili Powder",
                "Cinnamon", "Clove", "Cardamom", "Nutmeg", "Star Anise", "Fenugreek",
                "Mustard Seeds", "Fennel Seeds", "Caraway", "Nigella", "Bay Leaf", "Saffron",
                "Sumac", "Allspice", "Garam Masala", "Curry Powder", "Asafoetida", "Celery Seed",
                "Ginger Powder", "Garlic Powder", "Onion Powder", "White Pepper", "Ancho Chili",
                "Chipotle", "Cayenne", "Smoked Paprika", "Aleppo Pepper", "Chinese Five Spice",
                "Za'atar", "Berbere", "Ras el Hanout", "Advieh", "Dill Seed", "Mace",
                "Ajwain", "Panch Phoron", "Togarashi", "Urfa Biber", "Long Pepper", "Pink Peppercorn",
                "Galangal", "Kaffir Lime", "Lemongrass", "Tamarind"
            ],
            onAddToCart: { _, _ in }
        )
    }
}
