import SwiftData
import SwiftUI

struct HomeView: View {
    @Query var challenges: [Challenge]
    @Query var dailyProgress: [DailyProgress]
    @Environment(\.modelContext) private var modelContext

    func deleteChallenge(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let challenge = challenges[index]
                modelContext.delete(challenge)
            }
            
            do {
                try modelContext.save()
            } catch {
                print("Failed to delete challenge: \(error)")
            }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(challenges) { challenge in
                    NavigationLink(
                        destination: ChallengeView(challenge: challenge)
                    ) {
                        ChallengeRowView(challenge: challenge)
                    }
                }
                .onDelete(perform: deleteChallenge)
            }
            .navigationTitle("My Challenges")
            .toolbar {
                NavigationLink {
                    CreateChallengeView()
                } label: {
                    Image(systemName: "plus")
                }
                EditButton()
            }
            .overlay {
                if challenges.isEmpty {
                    ContentUnavailableView(
                        "No Challenges Yet",
                        systemImage: "star.fill",
                        description: Text(
                            "Add your first 30-day challenge to get started")
                    )
                }
            }
        }.onAppear {
            if !challenges.isEmpty {
                print(challenges[0].dailyProgress)
            }
        }
    }
}

struct ChallengeRowView: View {
    let challenge: Challenge

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerSection
            detailsSection
        }
        .padding(.vertical, 8)
    }

    private var headerSection: some View {
        HStack {
            Text(challenge.title)
                .font(.title3)
                .fontWeight(.semibold)

            Spacer()

            EmojiBadge(emoji: challenge.emoji)
        }
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Label("Wish", systemImage: "star")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(challenge.wish)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Label("Daily Action", systemImage: "checkmark.circle")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(challenge.dailyAction)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct EmojiBadge: View {
    let emoji: String

    var body: some View {
        Text(emoji)
            .font(.title)
            .frame(width: 50, height: 50)
            .background(.quaternary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    HomeView()
        .modelContainer(ThirtyDayMeApp.sharedModelContainer)
}
