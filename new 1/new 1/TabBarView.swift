import SwiftUI

// Shared Tab enum for selection
enum Tab {
    case home, cart, profile
}

// Helper to apply badge only where available
private struct CartBadgeModifier: ViewModifier {
    let count: Int?

    func body(content: Content) -> some View {
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
            if let count {
                content.badge(count)
            } else {
                content
            }
        } else {
            content
        }
    }
}

struct TabBarView<Home: View, Cart: View, Profile: View>: View {
    @Binding var selection: Tab
    let cartBadgeCount: Int?

    @ViewBuilder var home: () -> Home
    @ViewBuilder var cart: () -> Cart
    @ViewBuilder var profile: () -> Profile

    var body: some View {
        TabView(selection: $selection) {
            home()
                .tabItem { Label("Home", systemImage: "house") }
                .tag(Tab.home)

            cart()
                .tabItem { Label("Cart", systemImage: "cart") }
                .modifier(CartBadgeModifier(count: cartBadgeCount))
                .tag(Tab.cart)

            profile()
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
                .tag(Tab.profile)
        }
    }
}

#Preview {
    TabBarView(
        selection: .constant(.home),
        cartBadgeCount: 3,
        home: { Text("Home") },
        cart: { Text("Cart") },
        profile: { Text("Profile") }
    )
}
