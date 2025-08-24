import SwiftData
import SwiftUI

// MARK: - Models
struct ChallengeDay {
    var date: Date
    var col: Int
    var dayProgress: DailyProgress?
    var isLeftComplete: Bool
    var isRightComplete: Bool
    var isAccessible: Bool
    var isShown: Bool
}

// MARK: - Main View
struct ChallengeView: View {
    let challenge: Challenge
    let weekDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    let gap: CGFloat = 6

    var challengeGridInformation: [[ChallengeDay]] {
        generateDailyGridInformation()
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Challenge date range header
                VStack(spacing: 8) {
                    Text(challenge.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Start")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(challenge.startDate, style: .date)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right")
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("End")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(challenge.endDate, style: .date)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding(.horizontal, 40)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
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

                ForEach(challengeGridInformation.indices, id: \.self) { row in
                    GridRow {
                        ForEach(challengeGridInformation[row].indices, id: \.self) { col in
                            DayContainerView(
                                challengeDay: challengeGridInformation[row][col],
                                challenge: challenge,
                                gap: gap
                            )
                        }
                    }
                }
            }
        }
        }
        .padding()
        .onAppear() {
            print("I AINT GOT NO TIME FOR HTAT")
            print(challenge.dailyProgress)
        }
    }

}

// MARK: - Helper Methods
private extension ChallengeView {
    func generateDailyGridInformation() -> [[ChallengeDay]] {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        var challengeDays: [ChallengeDay] = []

        let startCol = calendar.component(.weekday, from: challenge.startDate) - 1
        var currentDate = challenge.startDate
 
        for i in 0..<startCol {
            let placeholderDate = calendar.date(byAdding: .day, value: -(startCol - i), to: challenge.startDate) ?? challenge.startDate
            let placeholderCol = calendar.component(.weekday, from: placeholderDate) - 1
            
            challengeDays.append(
                ChallengeDay(
                    date: placeholderDate, col: placeholderCol, dayProgress: nil, 
                    isLeftComplete: false, isRightComplete: false,
                    isAccessible: false, isShown: false
                ))
        }

        while currentDate <= challenge.endDate {
            let dayIdx = challenge.dailyProgress.firstIndex(where: { day in
                day.date == currentDate
            })
            let dayProgress = dayIdx.map { challenge.dailyProgress[$0] } ?? nil
            
            // Check if previous calendar day has a completed progress entry
            let previousDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            let isLeftComplete = challenge.dailyProgress.first(where: { 
                calendar.isDate($0.date, inSameDayAs: previousDate) 
            })?.completion ?? false
            
            // Check if next calendar day has a completed progress entry
            let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
            let isRightComplete = challenge.dailyProgress.first(where: { 
                calendar.isDate($0.date, inSameDayAs: nextDate) 
            })?.completion ?? false
            let today = calendar.startOfDay(for: Date())
            let currentDayStart = calendar.startOfDay(for: currentDate)
            let isAccessible = today >= currentDayStart
            let col = calendar.component(.weekday, from: currentDate) - 1
            
            challengeDays.append(
                ChallengeDay(
                    date: currentDate, col: col, dayProgress: dayProgress, isLeftComplete: isLeftComplete,
                    isRightComplete: isRightComplete,
                    isAccessible: isAccessible, isShown: true
                ))

            currentDate =
                calendar.date(byAdding: .day, value: 1, to: currentDate)
                ?? currentDate
        }
        
        let endCol = calendar.component(.weekday, from: challenge.endDate) - 1
        let daysToAdd = 6 - endCol
        
        for i in 1...daysToAdd {
            let placeholderDate = calendar.date(byAdding: .day, value: i, to: challenge.endDate) ?? challenge.endDate
            let placeholderCol = calendar.component(.weekday, from: placeholderDate) - 1
            
            challengeDays.append(
                ChallengeDay(
                    date: placeholderDate, col: placeholderCol, dayProgress: nil,
                    isLeftComplete: false, isRightComplete: false,
                    isAccessible: false, isShown: false
                ))
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
        let color = challengeDay.isLeftComplete ? Color.green : Color.clear
        let isViable = challengeDay.dayProgress?.completion
        let isLeftStreak = challengeDay.col != 0 && challengeDay.isLeftComplete
        let isRightStreak = challengeDay.col != 6 && challengeDay.isRightComplete
        
        
        if challengeDay.isShown {
            HStack(spacing: 0) {
                if isLeftStreak {
                    Rectangle()
                        .fill(color)
                        .frame(width: gap / 2)
                }

                DayView(challengeDay: challengeDay, challenge: challenge)

                if isRightStreak {
                    Rectangle()
                        .fill(challengeDay.isRightComplete ? Color.green : Color.clear)
                        .frame(width: gap / 2)
                }
            }
        } else {
            Color.clear
                .aspectRatio(1.0, contentMode: .fit)
        }
    }
}

struct DayView: View {
    @Environment(\.modelContext) private var modelContext
    
    let challengeDay: ChallengeDay
    let challenge: Challenge
    
    var body: some View {
        Button(action: toggleCompletion) {
            VStack(spacing: 3) {
                Text("\(Calendar.current.component(.day, from: challengeDay.date))")
                    .font(.body).foregroundStyle(.black)
                    .fontWeight(challengeDay.isAccessible == true ? .bold : .regular)
                if challengeDay.dayProgress?.completion == true {
                    Text("\(challenge.emoji)")
                        .font(.system(size: 12))
                }
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            .aspectRatio(1.0, contentMode: .fit)
            .background(challengeDay.dayProgress?.completion == true ? Color.gray.opacity(0.5) : Color.clear)
            .cornerRadius(5)
            .opacity(challengeDay.isAccessible ? 1.0 : 0.5)
        }
    }
    
    func toggleCompletion() {
        print("toggling completion for day: \(challengeDay.date)")
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
        if let challenge = challenges.last {
            ChallengeView(challenge: challenge)
        } else {
            Text("No challenges found")
        }
    }
}

#Preview {
    ChallengeViewPreview()
        .modelContainer(ThirtyDayMeApp.sharedModelContainer)
}
