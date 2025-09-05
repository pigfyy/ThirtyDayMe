import SwiftData
import SwiftUI

struct EditChallengeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let challenge: Challenge

    @State private var title: String
    @State private var wish: String
    @State private var dailyAction: String
    @State private var emoji: String

    @State private var startDate: Date
    @State private var endDate: Date
    
    init(challenge: Challenge) {
        self.challenge = challenge
        self.title = challenge.title
        self.wish = challenge.wish
        self.dailyAction = challenge.dailyAction
        self.emoji = challenge.emoji
        
        self.startDate = challenge.startDate
        self.endDate = challenge.endDate
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Challenge Information") {
                    TextField("Title", text: $title)
                    LabeledContent("Wish") {
                        TextField("What do you want to achieve?", text: $wish)
                    }
                    LabeledContent("Daily Action") {
                        TextField(
                            "What will you do every day?", text: $dailyAction)
                    }
                    LabeledContent("Emoji") {
                        TextField("", text: $emoji)
                            .onChange(of: emoji) { oldValue, newValue in
                                let trimmed = emoji.trimmingCharacters(
                                    in: .whitespacesAndNewlines)
                                if let last = trimmed.last, last.isEmoji {
                                    emoji = String(last)
                                } else {
                                    emoji = ""
                                }
                            }
                    }
                }

                Section("Advanced Settings") {
                    DatePicker(
                        "Start Date",
                        selection: $startDate,
                        displayedComponents: [.date]
                    )
                    DatePicker(
                        "End Date",
                        selection: $endDate,
                        in: startDate...,
                        displayedComponents: [.date]
                    )
                }

                Button("Submit") {
                    submitForm()
                }
                .disabled(title.isEmpty || wish.isEmpty || dailyAction.isEmpty)
            }.navigationTitle("Edit Challenge")
        }
    }

    private func submitForm() {
        challenge.title = title
        challenge.wish = wish
        challenge.dailyAction = dailyAction
        challenge.emoji = emoji
        
        challenge.startDate = startDate
        challenge.endDate = endDate

        do {
            try modelContext.save()
        } catch {
            print("Failed to save: \(error)")
        }

        dismiss()
    }
}

struct EditChallengeViewPreview: View {
    @Query var challenges: [Challenge]

    var body: some View {
        NavigationStack {
            if let challenge = challenges.last {
                EditChallengeView(challenge: challenge)
            } else {
                Text("Challenge doesn't exist")
            }
        }
    }
}

#Preview {
    EditChallengeViewPreview()
        .modelContainer(ThirtyDayMeApp.sharedModelContainer)
}
