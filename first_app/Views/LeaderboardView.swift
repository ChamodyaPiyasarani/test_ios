import SwiftUI

struct LeaderboardView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var leaderboardData: [LeaderboardEntry] = []
    
    var body: some View {
        ZStack {
            AppColors.backgroundColor.ignoresSafeArea()
            
            VStack {
                // Header
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(AppColors.textColor)
                            .font(.title2)
                    }
                    
                    Spacer()
                    
                    Text("Leaderboard")
                        .font(.title)
                        .foregroundColor(AppColors.textColor)
                    
                    Spacer()
                    
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
        .preferredColorScheme(.dark) // Keep leaderboard in dark theme for visibility
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
                .foregroundColor(AppColors.textColor)
                .frame(width: 30)
            
            VStack(alignment: .leading) {
                Text(entry.user.username)
                    .font(.headline)
                    .foregroundColor(AppColors.textColor)
                
                HStack {
                    ForEach(GameMode.allCases, id: \.self) { mode in
                        Text("\(mode.rawValue.prefix(1)):\(entry.user.highScore(for: mode))")
                            .font(.caption)
                            .foregroundColor(AppColors.secondaryTextColor)
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
        .background(AppColors.cardBackground)
        .cornerRadius(8)
    }
}
