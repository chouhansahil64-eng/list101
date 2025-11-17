//
//  FruitsView.swift
//  new 1
//
//  Created by Sahil Chouhan on 12/11/25.
//

import SwiftUI

struct FruitsView: View {
    let fruits: [String]
    let onAddToCart: (_ name: String, _ quantity: Int) -> Void

    @State private var selectedFruit: String?
    @State private var quantity: Int = 1
    @State private var showQuantitySheet: Bool = false

    // Simple adaptive grid for box-shaped tiles
    private let columns = [
        GridItem(.adaptive(minimum: 110), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(fruits, id: \.self) { fruit in
                    Button {
                        selectedFruit = fruit
                        quantity = 1
                        showQuantitySheet = true
                    } label: {
                        VStack(spacing: 8) {
                            // Optional: use system emoji as placeholder
                            Text(symbol(for: fruit))
                                .font(.system(size: 36))
                            Text(fruit)
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
                    .accessibilityLabel("Add \(fruit)")
                }
            }
            .padding()
        }
        .background(Color.appBackground)
        .navigationTitle("hello")
        .sheet(isPresented: $showQuantitySheet) {
            QuantitySheet(
                fruitName: selectedFruit ?? "",
                quantity: $quantity,
                onCancel: { showQuantitySheet = false },
                onAdd: {
                    if let name = selectedFruit {
                        onAddToCart(name, quantity)
                    }
                    showQuantitySheet = false
                }
            )
            .presentationDetents([PresentationDetent.height(260), .medium])
        }
    }

    private func symbol(for fruit: String) -> String {
        switch fruit.lowercased() {
        case "apple": return "🍎"
        case "banana": return "🍌"
        case "orange": return "🍊"
        case "grapes": return "🍇"
        case "strawberry": return "🍓"
        case "blueberry": return "🫐"
        case "mango": return "🥭"
        case "pineapple": return "🍍"
        case "watermelon": return "🍉"
        case "peach": return "🍑"
        case "pear": return "🍐"
        case "plum": return ""
        case "cherry": return "🍒"
        case "kiwi": return "🥝"
        case "pomegranate": return "🔴"
        case "papaya": return "🟠"
        case "guava": return "🟢"
        case "lychee": return "🔴"
        case "apricot": return "🟠"
        case "fig": return "🟣"
        case "cantaloupe": return "🟠"
        case "honeydew": return "🟢"
        case "lemon": return "🍋"
        case "lime": return "🟢"
        case "coconut": return "🥥"
        case "dragon fruit": return "🐉"
        case "raspberry": return "🔴"
        case "blackberry": return "🟣"
        default: return "🍏"
        }
    }
}

// Make this internal (shared) so SpicesView can use it
struct QuantitySheet: View {
    let fruitName: String
    @Binding var quantity: Int
    var onCancel: () -> Void
    var onAdd: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Add \(fruitName)")
                    .font(.headline)

                Stepper(value: $quantity, in: 1...50) {
                    HStack {
                        Text("Quantity")
                        Spacer()
                        Text("\(quantity)")
                            .font(.title3)
                            .monospacedDigit()
                    }
                }
                .padding(.horizontal)

                Spacer()

                HStack {
                    Button(role: .cancel) {
                        onCancel()
                    } label: {
                        Text("Cancel")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    Button {
                        onAdd()
                    } label: {
                        Text("Add to Cart")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal)
            }
            .padding(.top, 20)
        }
    }
}

#Preview {
    NavigationStack {
        FruitsView(
            fruits: [
                "Apple", "Banana", "Orange", "Grapes", "Strawberry", "Blueberry", "Mango",
                "Pineapple", "Watermelon", "Peach", "Pear", "Plum", "Cherry", "Kiwi"
            ],
            onAddToCart: { _, _ in }
        )
    }
}
