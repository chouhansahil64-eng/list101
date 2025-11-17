//
//  ContentView.swift
//  new 1
//
//  Created by Sahil Chouhan on 12/11/25.
//

import SwiftUI
import PhotosUI
import AudioToolbox

// Mid olive for borders (sourced from Theme.swift)
private let appMidGreen = Color.appBorder

// MARK: - Haptics & Sound

private enum Haptics {
    static func tap() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
        #endif
    }
}

private final class SoundPlayer {
    static let shared = SoundPlayer()

    // System sound IDs (Apple-provided short UI sounds)
    // 1104 is a subtle "Tock" used for key taps
    private let tapSoundID: SystemSoundID = 1104

    private init() {}

    func playTap() {
        AudioServicesPlaySystemSound(tapSoundID)
    }
}

// Reusable card effects modifier to keep all category tiles consistent
private struct CardEffects: ViewModifier {
    var cornerRadius: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            // Subtle background to make the image pop on any background
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            // Border
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(appMidGreen.opacity(0.9), lineWidth: 0.8)
            )
            // Inner highlight gradient for a soft glossy effect
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.18),
                                Color.white.opacity(0.04),
                                Color.black.opacity(0.02)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.softLight)
            )
            // Drop shadow for depth
            .shadow(color: .black.opacity(0.18), radius: 14, x: 0, y: 10)
    }
}

private extension View {
    func cardEffects(cornerRadius: CGFloat = 16) -> some View {
        modifier(CardEffects(cornerRadius: cornerRadius))
    }
}

// A reusable press animation: scales down on tap, then springs back
private struct PressableScale: ViewModifier {
    @Binding var isPressed: Bool
    var scale: CGFloat = 0.94
    var duration: CGFloat = 0.12

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? scale : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0.15), value: isPressed)
    }
}

private extension View {
    func pressableScale(isPressed: Binding<Bool>, scale: CGFloat = 0.94) -> some View {
        modifier(PressableScale(isPressed: isPressed, scale: scale))
    }
}

struct GroceryItem: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var quantity: Int
}

struct ContentView: View {
    @EnvironmentObject private var appLanguage: AppLanguage

    // MARK: - App State
    @State private var allItems: [GroceryItem] = [
        GroceryItem(name: "Apples", quantity: 1),
        GroceryItem(name: "Bananas", quantity: 1),
        GroceryItem(name: "Milk", quantity: 1),
        GroceryItem(name: "Bread", quantity: 1)
    ]

    // Today’s cart remains the primary array to preserve current behavior
    @State private var cart: [GroceryItem] = []

    // Additional carts keyed by date (normalized to midnight)
    @State private var cartsByDate: [Date: [GroceryItem]] = [:]

    // Date selection used when adding items from other tabs
    @State private var selectedDate: Date = Date()

    @State private var selectedTab: Tab = .home
    @State private var confirmClearCart: Bool = false

    // Home search state (not used for Search tab; kept if you later add Home search)
    @State private var homeSearchText: String = ""
    @FocusState private var isHomeSearchFocused: Bool

    // Search tab state
    @State private var searchText: String = ""

    // Navigation to sub-pages
    @State private var showFruits: Bool = false
    @State private var showSpices: Bool = false
    @State private var showHomeItems: Bool = false
    @State private var showVegetables: Bool = false
    @State private var showElectronics: Bool = false
    @State private var showCleaners: Bool = false

    // NEW: Navigation to the 100-items grid from "111"
    @State private var showAllItemsGrid: Bool = false

    // Profile state
    @State private var profileImage: Image? = nil
    @State private var showHistory: Bool = false
    @State private var showRepeatedItems: Bool = false
    @State private var showAboutUs: Bool = false

    // PhotosPicker state
    @State private var selectedPhotoItem: PhotosPickerItem? = nil

    // Persisted profile fields
    @AppStorage("profileName") private var profileName: String = ""
    @AppStorage("profileEmail") private var profileEmail: String = ""

    // Button pressed animation states
    @State private var pressed111 = false
    @State private var pressedFruits = false
    @State private var pressedSpices = false
    @State private var pressedHomeItems = false
    @State private var pressedVegetables = false
    @State private var pressedElectronics = false
    @State private var pressedCleaners = false

    // Filtered items for the Search tab (deduplicated by name, case-insensitive, trimmed)
    private var filteredItems: [GroceryItem] {
        let trimmedQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return [] }

        let matches = allItems.filter { $0.name.localizedCaseInsensitiveContains(trimmedQuery) }

        var seen = Set<String>()
        var unique: [GroceryItem] = []
        unique.reserveCapacity(matches.count)

        for item in matches {
            // Trim whitespace and normalize case/diacritics for the key
            let key = item.name
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            if !seen.contains(key) {
                seen.insert(key)
                unique.append(item) // keep first occurrence's quantity
            }
        }
        return unique
    }

    // Badge shows today's cart count
    private var cartBadgeCount: Int? {
        let todayItems = items(for: Date())
        return todayItems.isEmpty ? nil : todayItems.count
    }

    // Flatten all items across dates into a single list of (item, date)
    private var allCartEntries: [(item: GroceryItem, date: Date)] {
        var result: [(GroceryItem, Date)] = []
        let today = normalizedDay(Date())
        // Today's items
        result.append(contentsOf: cart.map { ($0, today) })
        // Other dates
        for (date, items) in cartsByDate {
            result.append(contentsOf: items.map { ($0, date) })
        }
        // Sort by date (oldest first), then by name
        return result.sorted { (lhs: (GroceryItem, Date), rhs: (GroceryItem, Date)) -> Bool in
            let lhsDay = normalizedDay(lhs.1)
            let rhsDay = normalizedDay(rhs.1)
            if lhsDay != rhsDay {
                return lhsDay < rhsDay
            } else {
                return lhs.0.name.localizedCaseInsensitiveCompare(rhs.0.name) == .orderedAscending
            }
        }
    }

    var body: some View {
        TabBarView(
            selection: $selectedTab,
            cartBadgeCount: cartBadgeCount,
            home: { homeTab },
            cart: { cartTab },
            profile: { profileTab }
        )
        .background(Color.appBackground)
        .task(id: selectedPhotoItem) {
            // Load the selected photo when it changes
            await loadSelectedPhoto()
        }
    }

    // MARK: - Home tab
    private var homeTab: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    // Button with asset "111" to load 100 unique grocery items
                    Button {
                        animateTap($pressed111) {
                            populateOneHundredUniqueGroceryItems()
                            showAllItemsGrid = true
                        }
                    } label: {
                        Image("111")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 210)
                            .cardEffects()
                            .padding(.horizontal)
                            .contentShape(Rectangle())
                            .accessibilityLabel(Text("load items accessibility"))
                    }
                    .pressableScale(isPressed: $pressed111)
                    .buttonStyle(.plain)
                    .padding(.top, 12)

                    // Hidden NavigationLink to the items grid
                    NavigationLink(
                        destination: ItemsGridView(
                            items: allItems,
                            onAddToCart: { item in
                                addToCart(item, on: selectedDate)
                            }
                        ),
                        isActive: $showAllItemsGrid
                    ) { EmptyView() }
                    .hidden()

                    // Fruits
                    Button {
                        animateTap($pressedFruits) {
                            showFruits = true
                        }
                    } label: {
                        Image("fruits")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 210)
                            .cardEffects()
                            .padding(.horizontal)
                            .contentShape(Rectangle())
                            .accessibilityLabel(Text("open fruits page"))
                    }
                    .pressableScale(isPressed: $pressedFruits)
                    .buttonStyle(.plain)
                    // Link right after button
                    NavigationLink(
                        destination: FruitsView(
                            fruits: fruitNames,
                            onAddToCart: { name, qty in
                                let item = GroceryItem(name: name, quantity: qty)
                                addToCart(item, on: selectedDate)
                            }
                        ),
                        isActive: $showFruits
                    ) { EmptyView() }
                    .hidden()

                    // Spices
                    Button {
                        animateTap($pressedSpices) {
                            showSpices = true
                        }
                    } label: {
                        Image("spices")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 210)
                            .cardEffects()
                            .padding(.horizontal)
                            .contentShape(Rectangle())
                            .accessibilityLabel(Text("open spices page"))
                    }
                    .pressableScale(isPressed: $pressedSpices)
                    .buttonStyle(.plain)
                    NavigationLink(
                        destination: SpicesView(
                            spices: spicesNames,
                            onAddToCart: { name, qty in
                                let item = GroceryItem(name: name, quantity: qty)
                                addToCart(item, on: selectedDate)
                            }
                        ),
                        isActive: $showSpices
                    ) { EmptyView() }
                    .hidden()

                    // Home Items
                    Button {
                        animateTap($pressedHomeItems) {
                            showHomeItems = true
                        }
                    } label: {
                        Image("home")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 210)
                            .cardEffects()
                            .padding(.horizontal)
                            .contentShape(Rectangle())
                            .accessibilityLabel(Text("open home items page"))
                    }
                    .pressableScale(isPressed: $pressedHomeItems)
                    .buttonStyle(.plain)
                    NavigationLink(
                        destination: HomeItemsView(
                            items: homeItemNames,
                            onAddToCart: { name, qty in
                                let item = GroceryItem(name: name, quantity: qty)
                                addToCart(item, on: selectedDate)
                            }
                        ),
                        isActive: $showHomeItems
                    ) { EmptyView() }
                    .hidden()

                    // Vegetables
                    Button {
                        animateTap($pressedVegetables) {
                            showVegetables = true
                        }
                    } label: {
                        Image("vegetables")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 210)
                            .cardEffects()
                            .padding(.horizontal)
                            .contentShape(Rectangle())
                            .accessibilityLabel(Text("open vegetables page"))
                    }
                    .pressableScale(isPressed: $pressedVegetables)
                    .buttonStyle(.plain)
                    NavigationLink(
                        destination: VegetablesView(
                            vegetables: vegetablesNames,
                            onAddToCart: { name, qty in
                                let item = GroceryItem(name: name, quantity: qty)
                                addToCart(item, on: selectedDate)
                            }
                        ),
                        isActive: $showVegetables
                    ) { EmptyView() }
                    .hidden()

                    // Electronics
                    Button {
                        animateTap($pressedElectronics) {
                            showElectronics = true
                        }
                    } label: {
                        Image("electronics")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 210)
                            .cardEffects()
                            .padding(.horizontal)
                            .contentShape(Rectangle())
                            .accessibilityLabel(Text("open electronics page"))
                    }
                    .pressableScale(isPressed: $pressedElectronics)
                    .buttonStyle(.plain)
                    NavigationLink(
                        destination: ElectronicsView(
                            electronics: electronicsNames,
                            onAddToCart: { name, qty in
                                let item = GroceryItem(name: name, quantity: qty)
                                addToCart(item, on: selectedDate)
                            }
                        ),
                        isActive: $showElectronics
                    ) { EmptyView() }
                    .hidden()

                    // Cleaners
                    Button {
                        animateTap($pressedCleaners) {
                            showCleaners = true
                        }
                    } label: {
                        Image("cleaner")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 210)
                            .cardEffects()
                            .padding(.horizontal)
                            .contentShape(Rectangle())
                            .accessibilityLabel(Text("open cleaning items page"))
                    }
                    .pressableScale(isPressed: $pressedCleaners)
                    .buttonStyle(.plain)
                    NavigationLink(
                        destination: CleanersView(
                            cleaners: cleanersNames,
                            onAddToCart: { name, qty in
                                let item = GroceryItem(name: name, quantity: qty)
                                addToCart(item, on: selectedDate)
                            }
                        ),
                        isActive: $showCleaners
                    ) { EmptyView() }
                    .hidden()
                }
                .padding(.bottom, 12)
            }
            .navigationTitle(Text("Grocery"))
            .toolbarTitleDisplayMode(.large)
            .background(Color.appBackground)
            .scrollContentBackgroundHiddenIfAvailable()
        }
    }

    // MARK: - Search tab
    private var searchTab: some View {
        NavigationStack {
            List {
                Section(header: Text("search results section")) {
                    if filteredItems.isEmpty {
                        Text("search type to search")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(filteredItems) { item in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(item.name)
                                    Text("Qty: \(item.quantity)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Button {
                                    addToCart(item, on: selectedDate)
                                } label: {
                                    Image(systemName: "cart.badge.plus")
                                        .foregroundStyle(.tint)
                                }
                                .buttonStyle(.borderless)
                                .accessibilityLabel(Text("Add \(item.name)"))
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
            .navigationTitle(Text("Search"))
            .toolbarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: Text("search prompt"))
        }
    }

    // MARK: - Cart tab (flat list of all items with date under each)
    private var cartTab: some View {
        NavigationStack {
            List {
                Section(header: Text("All cart items")) {
                    if allCartEntries.isEmpty {
                        Text("cart empty")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(Array(allCartEntries.enumerated()), id: \.element.item.id) { index, entry in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(entry.item.name)
                                    Spacer()
                                    Text("x\(entry.item.quantity)")
                                        .foregroundStyle(.secondary)
                                }
                                Text(formattedDate(entry.date))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    deleteEntry(atFlattenedIndex: index)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
            .navigationTitle(Text("Cart"))
            .toolbarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if !allCartEntries.isEmpty {
                        Button(role: .destructive) {
                            confirmClearCart = true
                        } label: {
                            Text("clear")
                        }
                        .accessibilityLabel(Text("clear cart accessibility"))
                    }
                }
            }
            .alert("confirm clear cart title", isPresented: $confirmClearCart) {
                Button("clear cart", role: .destructive) {
                    clearAll()
                }
                Button("cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to clear all items across all dates?")
            }
        }
    }

    // MARK: - Profile tab
    private var profileTab: some View {
        NavigationStack {
            Form {
                Section(header: Text("section profile")) {
                    HStack(alignment: .center, spacing: 12) {
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images, preferredItemEncoding: .automatic) {
                            ZStack {
                                if let image = profileImage {
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundStyle(.tint)
                                }
                            }
                            .frame(width: 64, height: 64)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color(.separator), lineWidth: 1))
                            .accessibilityLabel(Text("Change profile picture"))
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            TextField("your name", text: $profileName)
                                .textContentType(.name)
                                .submitLabel(.done)

                            TextField("your email", text: $profileEmail)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .textContentType(.emailAddress)
                                .submitLabel(.done)
                        }
                        Spacer()
                    }
                }

                Section(header: Text("History")) {
                    Button {
                        showHistory = true
                    } label: {
                        Label("View Order History", systemImage: "clock.arrow.circlepath")
                    }
                }

                Section(header: Text("Repeated Items")) {
                    Button {
                        showRepeatedItems = true
                    } label: {
                        Label("Show Frequently Bought", systemImage: "arrow.triangle.2.circlepath")
                    }
                }

                Section(header: Text("About Us")) {
                    Button {
                        showAboutUs = true
                    } label: {
                        Label("About This App", systemImage: "info.circle")
                    }
                }

                Section {
                    Button(role: .destructive) { } label: { Text("sign out") }
                }
            }
            .background(Color.appBackground)
            .scrollContentBackgroundHiddenIfAvailable()
            .navigationTitle(Text("Profile"))
            .toolbarTitleDisplayMode(.large)

            // Navigation destinations
            .navigationDestination(isPresented: $showHistory) {
                HistoryView()
            }
            .navigationDestination(isPresented: $showRepeatedItems) {
                RepeatedItemsView(allItems: allItems)
            }
            .navigationDestination(isPresented: $showAboutUs) {
                AboutUsView()
            }
        }
    }

    // MARK: - Lists for category views
    private var fruitNames: [String] {
        [
            "Apple", "Banana", "Orange", "Grapes", "Strawberry", "Blueberry", "Mango",
            "Pineapple", "Watermelon", "Peach", "Pear", "Plum", "Cherry", "Kiwi",
            "Pomegranate", "Papaya", "Guava", "Lychee", "Apricot", "Fig", "Cantaloupe",
            "Honeydew", "Lemon", "Lime", "Coconut", "Dragon Fruit", "Raspberry", "Blackberry"
        ]
    }

    private var spicesNames: [String] {
        [
            "Black Pepper", "Cumin", "Coriander", "Turmeric", "Paprika", "Chili Powder",
            "Cinnamon", "Clove", "Cardamom", "Nutmeg", "Star Anise", "Fenugreek",
            "Mustard Seeds", "Fennel Seeds", "Caraway", "Nigella", "Bay Leaf", "Saffron",
            "Sumac", "Allspice", "Garam Masala", "Curry Powder", "Asafoetida", "Celery Seed",
            "Ginger Powder", "Garlic Powder", "Onion Powder", "White Pepper", "Ancho Chili",
            "Chipotle", "Cayenne", "Smoked Paprika", "Aleppo Pepper", "Chinese Five Spice",
            "Za'atar", "Berbere", "Ras el Hanout", "Advieh", "Dill Seed", "Mace",
            "Ajwain", "Panch Phoron", "Togarashi", "Urfa Biber", "Long Pepper", "Pink Peppercorn",
            "Galangal", "Kaffir Lime", "Lemongrass", "Tamarind"
        ]
    }

    private var homeItemNames: [String] {
        [
            "Clock", "Chair", "Table", "Sofa", "Lamp", "Bookshelf", "Rug", "Curtains",
            "Mirror", "Vase", "Picture Frame", "Plant Pot", "Cushion", "Blanket", "Desk",
            "Office Chair", "Trash Can", "Laundry Basket", "Coat Rack", "Shoe Rack",
            "Wall Art", "Candle", "Towel", "Soap Dispenser", "Toothbrush Holder",
            "Shower Curtain", "Bath Mat", "Storage Box", "Hanger", "Doormat",
            "Cutlery Set", "Plates", "Bowls", "Mugs", "Glasses", "Kettle",
            "Toaster", "Blender", "Microwave Cover", "Spice Rack",
            "Knife Set", "Chopping Board", "Dish Rack", "Oven Mitts", "Apron",
            "Broom", "Dustpan", "Mop", "Bucket", "Tool Kit"
        ]
    }

    private var vegetablesNames: [String] {
        [
            "Tomato", "Potato", "Onion", "Garlic", "Ginger", "Carrot", "Cabbage", "Cauliflower",
            "Broccoli", "Spinach", "Lettuce", "Cucumber", "Bell Pepper", "Green Chili", "Peas",
            "Corn", "Eggplant", "Zucchini", "Pumpkin", "Radish", "Beetroot", "Okra", "Bitter Gourd",
            "Bottle Gourd", "Snake Gourd", "Drumstick", "Yam", "Sweet Potato", "Turnip", "Leek",
            "Celery", "Asparagus", "Artichoke", "Mushroom", "Spring Onion", "Scallion", "Chives",
            "Kale", "Swiss Chard", "Arugula", "Fenugreek Leaves", "Mustard Greens", "Dill",
            "Parsley", "Coriander Leaves", "Mint", "Curry Leaves", "Green Beans", "Cluster Beans",
            "Ridge Gourd", "Ivy Gourd"
        ]
    }

    private var electronicsNames: [String] {
        [
            "Smartphone", "Laptop", "Tablet", "Desktop PC", "Monitor", "Smart TV", "Headphones",
            "Earbuds", "Bluetooth Speaker", "Soundbar", "Smartwatch", "Fitness Tracker",
            "Camera", "DSLR", "Action Camera", "Drone", "Game Console", "VR Headset",
            "Keyboard", "Mouse", "Printer", "Scanner", "External Hard Drive", "SSD",
            "USB Flash Drive", "Router", "Wi‑Fi Extender", "Smart Bulb", "Smart Plug",
            "Power Bank", "Charging Cable", "Wireless Charger", "Car Charger", "Microphone",
            "Webcam", "Projector", "E‑reader", "Graphics Tablet", "Smart Doorbell",
            "Smart Lock", "Thermostat", "Air Purifier", "Robot Vacuum", "Electric Kettle",
            "Induction Cooktop", "Mixer Grinder", "Hair Dryer", "Trimmer", "Electric Toothbrush"
        ]
    }

    private var cleanersNames: [String] {
        [
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
        ]
    }

    // MARK: - Actions and helpers
    private func addNewSampleItem() {
        let names = ["Eggs", "Tomatoes", "Onions", "Cheese", "Yogurt", "Chicken", "Rice"]
        let name = names.randomElement() ?? "Item"
        let quantity = Int.random(in: 1...5)
        let newItem = GroceryItem(name: name, quantity: quantity)
        allItems.append(newItem)
        addToCart(newItem, on: selectedDate)
    }

    // Build exactly 100 unique grocery items (by name) without repeats
    private func populateOneHundredUniqueGroceryItems() {
        // Source pool of names from all category lists combined
        let pool = (fruitNames + spicesNames + homeItemNames + vegetablesNames + electronicsNames + cleanersNames)
        // Deduplicate names case/diacritic-insensitively and trim whitespace
        var seen = Set<String>()
        var uniqueNames: [String] = []
        uniqueNames.reserveCapacity(100)

        for raw in pool {
            let key = raw.trimmingCharacters(in: .whitespacesAndNewlines)
                .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            if !seen.contains(key) {
                seen.insert(key)
                uniqueNames.append(raw.trimmingCharacters(in: .whitespacesAndNewlines))
                if uniqueNames.count == 100 { break }
            }
        }

        // If the pool had fewer than 100 unique names, just use what we have
        allItems = uniqueNames.map { GroceryItem(name: $0, quantity: 1) }
    }

    private func buildItems(from names: [String], count: Int) -> [GroceryItem] {
        var items: [GroceryItem] = []
        items.reserveCapacity(count)
        for i in 0..<count {
            let name = names[i % names.count]
            let quantity = (i % 5) + 1
            items.append(GroceryItem(name: name, quantity: quantity))
        }
        return items
    }

    // Normalize a Date to midnight for dictionary keys
    private func normalizedDay(_ date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }

    // Get items for a date (today uses the main cart; others from dictionary)
    private func items(for date: Date) -> [GroceryItem] {
        let day = normalizedDay(date)
        let today = normalizedDay(Date())
        if day == today {
            return cart
        } else {
            return cartsByDate[day] ?? []
        }
    }

    private func setItems(_ items: [GroceryItem], for date: Date) {
        let day = normalizedDay(date)
        let today = normalizedDay(Date())
        if day == today {
            cart = items
        } else {
            cartsByDate[day] = items
        }
    }

    private func addToCart(_ item: GroceryItem, on date: Date? = nil) {
        let targetDate = date ?? Date()
        let day = normalizedDay(targetDate)
        let today = normalizedDay(Date())

        if day == today {
            if let index = cart.firstIndex(where: { $0.name == item.name }) {
                cart[index].quantity += item.quantity
            } else {
                cart.append(item)
            }
        } else {
            var items = cartsByDate[day] ?? []
            if let index = items.firstIndex(where: { $0.name == item.name }) {
                items[index].quantity += item.quantity
            } else {
                items.append(item)
            }
            cartsByDate[day] = items
        }
    }

    // Delete a flattened entry (by index in allCartEntries)
    private func deleteEntry(atFlattenedIndex index: Int) {
        let entries = allCartEntries
        guard index >= 0 && index < entries.count else { return }
        let entry = entries[index]
        let day = normalizedDay(entry.date)
        let today = normalizedDay(Date())

        if day == today {
            if let idx = cart.firstIndex(where: { $0.id == entry.item.id }) {
                cart.remove(at: idx)
            }
        } else {
            var items = cartsByDate[day] ?? []
            if let idx = items.firstIndex(where: { $0.id == entry.item.id }) {
                items.remove(at: idx)
                cartsByDate[day] = items
            }
        }
    }

    // Clear everything across all dates
    private func clearAll() {
        cart.removeAll()
        cartsByDate.removeAll()
    }

    // Kept for compatibility (not used in flat list UI)
    private func deleteFromCart(for date: Date, at offsets: IndexSet) {
        var items = items(for: date)
        items.remove(atOffsets: offsets)
        setItems(items, for: date)
    }

    private func clearCart(for date: Date) {
        setItems([], for: date)
    }

    private func deleteFromCart(at offsets: IndexSet) {
        deleteFromCart(for: selectedDate, at: offsets)
    }

    // Helper to trigger the press animation, haptic, and sound, then run an action
    private func animateTap(_ flag: Binding<Bool>, action: @escaping () -> Void) {
        // Haptic + sound immediately on tap
        Haptics.tap()
        SoundPlayer.shared.playTap()

        flag.wrappedValue = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            flag.wrappedValue = false
            action()
        }
    }

    // Load selected photo into profileImage
    private func loadSelectedPhoto() async {
        guard let item = selectedPhotoItem else { return }
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                profileImage = Image(uiImage: uiImage)
            }
        } catch {
            // Handle failures silently for now; you could add error UI if desired
            print("Failed to load selected photo: \(error)")
        }
    }

    // MARK: - Date formatting
    private func formattedDate(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fmt.timeStyle = .none
        return fmt.string(from: normalizedDay(date))
    }
}

// Helper to keep compatibility where scrollContentBackground(.hidden) is not available
private extension View {
    @ViewBuilder
    func scrollContentBackgroundHiddenIfAvailable() -> some View {
        if #available(iOS 16.0, *) {
            self.scrollContentBackground(.hidden)
        } else {
            self
        }
    }
}

// MARK: - Profile destinations (placeholders to expand)
private struct HistoryView: View {
    var body: some View {
        List {
            Section("Recent Orders") {
                Text("No orders yet.")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Order History")
    }
}

private struct RepeatedItemsView: View {
    let allItems: [GroceryItem]
    var body: some View {
        List {
            Section("Frequently Bought") {
                if allItems.isEmpty {
                    Text("No items yet.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(allItems) { item in
                        HStack {
                            Text(item.name)
                            Spacer()
                            Text("x\(item.quantity)")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Repeated Items")
    }
}

private struct AboutUsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("About Us")
                    .font(.largeTitle).bold()
                Text("This app helps you browse, search, and add grocery items to your cart quickly. Explore categories, view your order history, and manage your profile.")
                Text("Version 1.0")
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle("About Us")
    }
}

#Preview {
    ContentView()
        .environmentObject(AppLanguage(defaultIdentifier: "en"))
        .environment(\.locale, Locale(identifier: "en"))
}
