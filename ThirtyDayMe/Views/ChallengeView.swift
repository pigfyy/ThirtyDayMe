import SwiftData
import SwiftUI

// MARK: - Models
struct ChallengeDay {
    var date: Date
    var col: Int
    var dayProgress: DailyProgress?
    var isAccessible: Bool
    var isShown: Bool
}

// MARK: - Main View
struct ChallengeView: View {
    let challenge: Challenge
    let weekDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    let gap: CGFloat = 6

    @State private var challengeGridInformation: [[ChallengeDay]] = []

    var body: some View {
        ScrollView {
            if challenge.modelContext == nil {
                ContentUnavailableView(
                    "Challenge Deleted",
                    systemImage: "trash"
                )
            } else {
                VStack(spacing: 20) {
                    headerSection

                    // Calendar grid
                    Grid(horizontalSpacing: 0, verticalSpacing: gap) {
                        GridRow {
                            ForEach(weekDays, id: \.self) { day in
                                Text("\(day)")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, 3)
                            }
                        }

                        ForEach(challengeGridInformation.indices, id: \.self) {
                            row in
                            GridRow {
                                ForEach(
                                    challengeGridInformation[row].indices,
                                    id: \.self
                                ) { col in
                                    DayContainerView(
                                        challengeDay: challengeGridInformation[
                                            row][
                                                col],
                                        challenge: challenge,
                                        gap: gap
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(
                    destination: EditChallengeView(challenge: challenge)
                ) {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
        .navigationTitle(challenge.title)
        .navigationBarTitleDisplayMode(.automatic)
        .onAppear {
            challengeGridInformation = generateDailyGridInformation()
        }
        .onChange(of: challenge.dailyProgress) { _, _ in
            challengeGridInformation = generateDailyGridInformation()
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Wish")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                Text(challenge.wish)
                    .font(.body)
            }

            Divider()

            VStack(alignment: .leading, spacing: 4) {
                Text("Daily Action")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                Text(challenge.dailyAction)
                    .font(.body)
            }

            Divider()

            HStack(spacing: 32) {
                VStack (alignment: .leading) {
                    Text("Start Date")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    Text(challenge.startDate.formatted(.dateTime.month().day()))
                        .font(.body)
                }
                
                
                HStack(spacing: 0) {
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.secondary)

                    Image(systemName: "arrowtriangle.right.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                    
                
                VStack (alignment: .leading) {
                    Text("End Date")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    Text(challenge.endDate.formatted(.dateTime.month().day()))
                        .font(.body)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Helper Methods
extension ChallengeView {
    fileprivate func generateDailyGridInformation() -> [[ChallengeDay]] {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        var challengeDays: [ChallengeDay] = []

        let startCol =
            calendar.component(.weekday, from: challenge.startDate) - 1
        var currentDate = challenge.startDate

        for i in 0..<startCol {
            let placeholderDate =
                calendar.date(
                    byAdding: .day, value: -(startCol - i),
                    to: challenge.startDate) ?? challenge.startDate
            let placeholderCol =
                calendar.component(.weekday, from: placeholderDate) - 1

            challengeDays.append(
                ChallengeDay(
                    date: placeholderDate, col: placeholderCol,
                    dayProgress: nil,
                    isAccessible: false, isShown: false
                ))
        }

        var loopCount = 0
        let maxDays = 366  // Prevent infinite loops

        while currentDate <= challenge.endDate && loopCount < maxDays {
            loopCount += 1

            let dayIdx = challenge.dailyProgress.firstIndex(where: { day in
                calendar.isDate(day.date, inSameDayAs: currentDate)
            })
            let dayProgress = dayIdx.map { challenge.dailyProgress[$0] } ?? nil

            let today = calendar.startOfDay(for: Date())
            let currentDayStart = calendar.startOfDay(for: currentDate)
            let isAccessible = today >= currentDayStart
            let col = calendar.component(.weekday, from: currentDate) - 1

            challengeDays.append(
                ChallengeDay(
                    date: currentDate, col: col, dayProgress: dayProgress,
                    isAccessible: isAccessible, isShown: true
                ))

            currentDate =
                calendar.date(byAdding: .day, value: 1, to: currentDate)
                ?? currentDate
        }

        let endCol = calendar.component(.weekday, from: challenge.endDate) - 1
        let daysToAdd = 6 - endCol

        if daysToAdd > 0 {
            for i in 1...daysToAdd {
                let placeholderDate =
                    calendar.date(
                        byAdding: .day, value: i, to: challenge.endDate)
                    ?? challenge.endDate
                let placeholderCol =
                    calendar.component(.weekday, from: placeholderDate) - 1

                challengeDays.append(
                    ChallengeDay(
                        date: placeholderDate, col: placeholderCol,
                        dayProgress: nil,
                        isAccessible: false, isShown: false
                    ))
            }
        }

        // Group challengeDays into rows of 7 days each
        var rows: [[ChallengeDay]] = []
        var currentRow: [ChallengeDay] = []

        // Sort by date first to ensure proper ordering
        let sortedDays = challengeDays.sorted { $0.date < $1.date }

        for day in sortedDays {
            currentRow.append(day)

            // When we have 7 days (a complete week), add to rows and start new row
            if currentRow.count == 7 {
                rows.append(currentRow)
                currentRow = []
            }
        }

        // Add any remaining days as the last incomplete row
        if !currentRow.isEmpty {
            rows.append(currentRow)
        }

        return rows
    }
}

// MARK: - Subviews
struct DayContainerView: View {
    let challengeDay: ChallengeDay
    let challenge: Challenge
    let gap: CGFloat

    var body: some View {
        let calendar = Calendar.current
        let isViable = challengeDay.dayProgress?.completion ?? false

        // Dynamically check if previous day is complete
        let previousDate =
            calendar.date(byAdding: .day, value: -1, to: challengeDay.date)
            ?? challengeDay.date
        let isLeftComplete =
            challenge.dailyProgress.first(where: {
                calendar.isDate($0.date, inSameDayAs: previousDate)
            })?.completion ?? false

        // Dynamically check if next day is complete
        let nextDate =
            calendar.date(byAdding: .day, value: 1, to: challengeDay.date)
            ?? challengeDay.date
        let isRightComplete =
            challenge.dailyProgress.first(where: {
                calendar.isDate($0.date, inSameDayAs: nextDate)
            })?.completion ?? false

        let hasLeftStreak = isViable && challengeDay.col != 0 && isLeftComplete
        let hasRightStreak =
            isViable && challengeDay.col != 6 && isRightComplete

        HStack(spacing: 0) {
            Rectangle()
                .fill(hasLeftStreak ? Color.gray.opacity(0.5) : Color.clear)
                .frame(width: gap / 2)

            DayView(
                challengeDay: challengeDay,
                challenge: challenge,
                hasLeftStreak: hasLeftStreak,
                hasRightStreak: hasRightStreak,
                gap: gap
            )

            Rectangle()
                .fill(
                    hasRightStreak ? Color.gray.opacity(0.5) : Color.clear
                )
                .frame(width: gap / 2)
        }
    }
}

struct DayView: View {
    @Environment(\.modelContext) private var modelContext

    let challengeDay: ChallengeDay
    let challenge: Challenge
    let hasLeftStreak: Bool
    let hasRightStreak: Bool
    let gap: CGFloat

    var body: some View {
        let cornerRadius: CGFloat = 8
        let isComplete = challengeDay.dayProgress?.completion == true

        VStack(spacing: 3) {
            Text(
                "\(Calendar.current.component(.day, from: challengeDay.date))"
            )
            .font(.system(size: 15)).foregroundStyle(.primary)
            .fontWeight(
                challengeDay.isAccessible == true ? .bold : .regular)
            if isComplete {
                Text("\(challenge.emoji)")
                    .font(.system(size: 10))
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .aspectRatio(1.0, contentMode: .fit)
        .background(
            challengeDay.dayProgress?.completion == true
                ? Color.gray.opacity(0.5) : Color.clear
        )
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: hasLeftStreak ? 0 : cornerRadius,
                bottomLeadingRadius: hasLeftStreak ? 0 : cornerRadius,
                bottomTrailingRadius: hasRightStreak ? 0 : cornerRadius,
                topTrailingRadius: hasRightStreak ? 0 : cornerRadius
            )
        )
        .opacity(
            !challengeDay.isShown ? 0 : challengeDay.isAccessible ? 1.0 : 0.5
        )
        .onTapGesture {
            if challengeDay.isAccessible && challengeDay.isShown {
                toggleCompletion()
            }
        }
    }

    func toggleCompletion() {
        if let dayProgress = challengeDay.dayProgress {
            dayProgress.completion.toggle()
        } else {
            let newDailyProgress = DailyProgress(
                date: challengeDay.date,
                completion: true,
                challenge: challenge
            )

            modelContext.insert(newDailyProgress)
        }

        do {
            try modelContext.save()
        } catch {
            print("Failed to save: \(error)")
        }
    }
}

// MARK: - Previews
struct ChallengeViewPreview: View {
    @Query var challenges: [Challenge]

    var body: some View {
        NavigationStack {
            if let challenge = challenges.last {
                ChallengeView(challenge: challenge)
            } else {
                Text("No challenges found")
            }
        }
    }
}

#Preview {
    ChallengeViewPreview()
        .modelContainer(ThirtyDayMeApp.sharedModelContainer)
}
