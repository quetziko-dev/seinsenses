import SwiftUI

struct ContentView: View {
    @State private var selectedTab: TabItem = .home
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Inicio", systemImage: "house.fill")
                }
                .tag(TabItem.home)
            
            PhysicalView()
                .tabItem {
                    Label("Físico", systemImage: "figure.walk")
                }
                .tag(TabItem.physical)
            
            EmotionalView()
                .tabItem {
                    Label("Emocional", systemImage: "heart.fill")
                }
                .tag(TabItem.emotional)
            
            SocialView()
                .tabItem {
                    Label("Social", systemImage: "person.2.fill")
                }
                .tag(TabItem.social)
            
            MoreView()
                .tabItem {
                    Label("Más", systemImage: "ellipsis.circle")
                }
                .tag(TabItem.more)
        }
        .accentColor(.themeTeal)
    }
}

enum TabItem: Int, CaseIterable {
    case home = 0
    case physical = 1
    case emotional = 2
    case social = 3
    case more = 4
    
    var title: String {
        switch self {
        case .home: return "Inicio"
        case .physical: return "Físico"
        case .emotional: return "Emocional"
        case .social: return "Social"
        case .more: return "Más"
        }
    }
    
    var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .physical: return "figure.walk"
        case .emotional: return "heart.fill"
        case .social: return "person.2.fill"
        case .more: return "ellipsis.circle"
        }
    }
}

#Preview {
    ContentView()
}
