import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 4) {
                        Text("POLARIS")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .tracking(8)
                        Text("by North Star Unltd")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 60)
                    .padding(.bottom, 40)
                    
                    // Game List
                    ScrollView {
                        VStack(spacing: 12) {
                            NavigationLink(destination: WordleView()) {
                                GameCard(title: "Wordle", description: "Guess the hidden word in 6 attempts", emoji: "💬", color: .green)
                            }
                            .buttonStyle(.plain)
                            GameCard(title: "Shikaku", description: "Divide the grid using number clues", emoji: "⬛", color: .blue)
                            GameCard(title: "Connections", description: "Find the hidden link between word groups", emoji: "🔗", color: .purple)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct GameCard: View {
    let title: String
    let description: String
    let emoji: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Text(emoji)
                .font(.system(size: 32))
                .frame(width: 56, height: 56)
                .background(color.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                Text(description)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
                .font(.system(size: 14, weight: .semibold))
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    ContentView()
}
