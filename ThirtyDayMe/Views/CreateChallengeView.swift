import SwiftData
import SwiftUI

struct CreateChallengeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var wish = ""
    @State private var dailyAction = ""
    @State private var emoji = "✅"

    var body: some View {
        VStack {
            Text("Create Challenge")
            Form {
                Section {
                    LabeledContent("Title") {
                        TextField("", text: $title)
                    }
                    LabeledContent("Wish") {
                        TextField("", text: $wish)
                    }
                    LabeledContent("Daily Action") {
                        TextField("", text: $dailyAction)
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

                Section {
                    Button("Submit") {
                        submitForm()
                    }
                }
            }
        }
    }

    private func submitForm() {
        let newChallenge = Challenge(
            title: title, wish: wish, dailyAction: dailyAction, emoji: emoji,
            startDate: Date(),
            endDate: Calendar.current.date(
                byAdding: .day, value: 29, to: Date())!
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
