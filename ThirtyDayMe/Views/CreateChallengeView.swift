import SwiftData
import SwiftUI

struct CreateChallengeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var wish = ""
    @State private var dailyAction = ""
    @State private var emoji = "✅"

    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(
        byAdding: .day, value: 29, to: Date())!

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
            }.navigationTitle("Create Challenge")
        }
    }

    private func submitForm() {
        let newChallenge = Challenge(
            title: title, wish: wish, dailyAction: dailyAction, emoji: emoji,
            startDate: startDate,
            endDate: endDate
        )

        modelContext.insert(newChallenge)

        do {
            try modelContext.save()
        } catch {
            print("Failed to save: \(error)")
        }

        dismiss()
    }
}

#Preview {
    CreateChallengeView()
        .modelContainer(ThirtyDayMeApp.sharedModelContainer)
}
