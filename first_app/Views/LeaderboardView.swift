import SwiftUI

struct LeaderboardView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var leaderboardData: [LeaderboardEntry] = []
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                // Header
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                    
                    Spacer()
                    
                    Text("Leaderboard")
                        .font(.title)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Invisible spacer for centering
                    Image(systemName: "xmark")
                        .font(.title2)
                        .opacity(0)
                }
                .padding()
                
                // Leaderboard List
                List(leaderboardData) { entry in
                    LeaderboardRow(entry: entry)
                        .listRowBackground(Color.clear)
                }
                .listStyle(PlainListStyle())
            }
        }
        .onAppear {
            loadLeaderboardData()
        }
    }
    
    private func loadLeaderboardData() {
        let users = StorageService.shared.getLeaderboard()
        leaderboardData = users.enumerated().map { index, user in
            LeaderboardEntry(
                rank: index + 1,
                user: user
            )
        }
    }
}

struct LeaderboardEntry: Identifiable {
    let id = UUID()
    let rank: Int
    let user: User
}

struct LeaderboardRow: View {
    let entry: LeaderboardEntry
    
    var body: some View {
        HStack {
            Text("\(entry.rank)")
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 30)
            
            VStack(alignment: .leading) {
                Text(entry.user.username)
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack {
                    ForEach(GameMode.allCases, id: \.self) { mode in
                        Text("\(mode.rawValue.prefix(1)):\(entry.user.highScore(for: mode))")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 4)
                    }
                }
            }
            
            Spacer()
            
            Text("\(entry.user.highScore(for: .hard))")
                .font(.title2)
                .foregroundColor(.yellow)
        }
        .padding(.vertical, 8)
    }
}
