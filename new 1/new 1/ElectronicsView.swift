//
//  ElectronicsView.swift
//  new 1
//
//  Created by Sahil Chouhan on 12/11/25.
//

import SwiftUI

struct ElectronicsView: View {
    let electronics: [String]
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
                ForEach(electronics, id: \.self) { item in
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
        .navigationTitle("Electronics")
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
        if n.contains("phone") { return "📱" }
        if n.contains("laptop") || n.contains("pc") { return "💻" }
        if n.contains("tablet") { return "📱" }
        if n.contains("tv") || n.contains("monitor") { return "🖥️" }
        if n.contains("headphone") || n.contains("earbud") { return "🎧" }
        if n.contains("speaker") || n.contains("soundbar") { return "🔊" }
        if n.contains("watch") || n.contains("tracker") { return "⌚️" }
        if n.contains("camera") || n.contains("drone") { return "📷" }
        if n.contains("game") || n.contains("console") || n.contains("vr") { return "🎮" }
        if n.contains("keyboard") { return "⌨️" }
        if n.contains("mouse") { return "🖱️" }
        if n.contains("printer") || n.contains("scanner") { return "🖨️" }
        if n.contains("router") || n.contains("wifi") { return "📶" }
        if n.contains("bulb") || n.contains("plug") { return "💡" }
        if n.contains("power") || n.contains("charger") || n.contains("battery") { return "🔋" }
        if n.contains("microphone") { return "🎙️" }
        if n.contains("webcam") { return "📷" }
        if n.contains("projector") { return "📽️" }
        if n.contains("reader") { return "📚" }
        if n.contains("doorbell") || n.contains("lock") { return "🔔" }
        if n.contains("thermostat") { return "🌡️" }
        if n.contains("purifier") || n.contains("vacuum") { return "🧹" }
        if n.contains("kettle") || n.contains("cooktop") || n.contains("mixer") { return "🍳" }
        if n.contains("hair") || n.contains("trimmer") || n.contains("toothbrush") { return "🪒" }
        return "🔌"
    }
}

#Preview {
    NavigationStack {
        ElectronicsView(
            electronics: [
                "Smartphone", "Laptop", "Tablet", "Desktop PC", "Monitor", "Smart TV", "Headphones",
                "Earbuds", "Bluetooth Speaker", "Soundbar", "Smartwatch", "Fitness Tracker",
                "Camera", "DSLR", "Action Camera", "Drone", "Game Console", "VR Headset",
                "Keyboard", "Mouse", "Printer", "Scanner", "External Hard Drive", "SSD",
                "USB Flash Drive", "Router", "Wi‑Fi Extender", "Smart Bulb", "Smart Plug",
                "Power Bank", "Charging Cable", "Wireless Charger", "Car Charger", "Microphone",
                "Webcam", "Projector", "E‑reader", "Graphics Tablet", "Smart Doorbell",
                "Smart Lock", "Thermostat", "Air Purifier", "Robot Vacuum", "Electric Kettle",
                "Induction Cooktop", "Mixer Grinder", "Hair Dryer", "Trimmer", "Electric Toothbrush"
            ],
            onAddToCart: { _, _ in }
        )
    }
}
