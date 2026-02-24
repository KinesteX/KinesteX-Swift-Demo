//
//  ClientPlanDetailView.swift
//  KinesteXSDKDemoSwift
//
//  Created on 2/24/26.
//

import SwiftUI

// MARK: - Client Plan Detail View

struct ClientPlanDetailView: View {
    let plan: ClientPlan
    let personalPlan: PersonalPlan?
    @Binding var expandedWeeks: [Int: Bool]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            planHeaderImage
            levelAndCategoryBadges
            bodyPartsTags
            personalPlanProgress
            weeksList
        }
    }

    // MARK: - Header Image

    @ViewBuilder
    private var planHeaderImage: some View {
        if let imgUrl = plan.img_url, let url = URL(string: imgUrl) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: 140)
                    .clipped()
                    .cornerRadius(10)
                    .overlay(
                        VStack {
                            Spacer()
                            Text(plan.title)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .shadow(radius: 6)
                                .padding(8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        }
                    )
            } placeholder: {
                ProgressView()
                    .frame(height: 120)
            }
            .padding(.horizontal)
        } else {
            Text(plan.title)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal)
        }
    }

    // MARK: - Level & Category Badges

    @ViewBuilder
    private var levelAndCategoryBadges: some View {
        HStack(spacing: 6) {
            if let level = plan.level {
                Text(level.capitalized)
                    .font(.caption2)
                    .foregroundColor(.green)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.green.opacity(0.2).cornerRadius(4))
            }
            if let levels = plan.category_levels {
                ForEach(Array(levels.enumerated()), id: \.offset) { _, cl in
                    if let name = cl.name, let score = cl.score {
                        Text("\(name.capitalized) \(score)")
                            .font(.caption2)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.gray.opacity(0.3).cornerRadius(4))
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Body Parts Tags

    @ViewBuilder
    private var bodyPartsTags: some View {
        if let bodyParts = plan.body_parts, !bodyParts.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(bodyParts, id: \.self) { part in
                        Text(part)
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(4)
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Personal Plan Progress

    @ViewBuilder
    private var personalPlanProgress: some View {
        if let pp = personalPlan {
            HStack(spacing: 12) {
                if let week = pp.current_week {
                    HStack(spacing: 3) {
                        Text("Week")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        Text("\(week)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
                if let day = pp.current_day {
                    HStack(spacing: 3) {
                        Text("Day")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        Text("\(day)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
                if pp.re_test_assessment == true {
                    HStack(spacing: 2) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.caption2)
                        Text("Re-test")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Weeks List

    @ViewBuilder
    private var weeksList: some View {
        if let weeks = plan.weeks {
            let sortedWeeks = weeks.sorted { ($0.week_number ?? 0) < ($1.week_number ?? 0) }
            ForEach(Array(sortedWeeks.enumerated()), id: \.offset) { index, week in
                WeekSectionView(
                    week: week,
                    index: index,
                    isFirst: index == 0,
                    isExpanded: Binding(
                        get: { expandedWeeks[index] ?? false },
                        set: { expandedWeeks[index] = $0 }
                    )
                )
            }
        }
    }
}

// MARK: - Week Section View

struct WeekSectionView: View {
    let week: ClientWeek
    let index: Int
    let isFirst: Bool
    @Binding var isExpanded: Bool

    private var weekNum: Int { week.week_number ?? (index + 1) }
    private var isActive: Bool { week.isActive ?? false }
    private var isComplete: Bool { week.isComplete ?? false }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            weekHeader
            if isExpanded, let days = week.days {
                let sortedDays = days.sorted { ($0.day_number ?? 0) < ($1.day_number ?? 0) }
                ForEach(Array(sortedDays.enumerated()), id: \.offset) { _, day in
                    DayRowView(day: day)
                }
            }
        }
        .padding(.horizontal)
        .onAppear {
            if !isExpanded && (isFirst || isActive) {
                isExpanded = true
            }
        }
    }

    @ViewBuilder
    private var weekHeader: some View {
        Button(action: {
            withAnimation { isExpanded.toggle() }
        }) {
            HStack {
                HStack(spacing: 6) {
                    Text("Week \(weekNum)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    if isComplete {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption2)
                    } else if isActive {
                        Text("Active")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.yellow.opacity(0.2).cornerRadius(3))
                    }

                    if let days = week.days {
                        let completedCount = days.filter { $0.completed }.count
                        Text("\(completedCount)/\(days.count)")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .foregroundColor(.green)
                    .font(.caption)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .background(
                isActive
                    ? Color.green.opacity(0.15)
                    : Color.gray.opacity(0.2)
            )
            .cornerRadius(8)
        }
    }
}

// MARK: - Day Row View

struct DayRowView: View {
    let day: ClientDay

    private var isRest: Bool { day.is_rest ?? false }
    private var isDone: Bool { day.completed }
    private var dayNum: Int { day.day_number ?? 0 }

    var body: some View {
        HStack(spacing: 8) {
            dayLabel
            if isRest {
                Text("Rest")
                    .font(.caption2)
                    .foregroundColor(.gray)
            } else if let workout = day.workout {
                workoutContent(workout)
            }
            Spacer()
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(rowBackground)
        .cornerRadius(6)
        .padding(.horizontal, 2)
        .padding(.vertical, 1)
    }

    @ViewBuilder
    private var dayLabel: some View {
        VStack(spacing: 2) {
            Text(day.translation?.title ?? day.title ?? "D\(dayNum)")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(isRest ? .yellow : .white)
                .lineLimit(1)
            if isDone {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.caption2)
            } else if isRest {
                Image(systemName: "moon.fill")
                    .foregroundColor(.yellow)
                    .font(.caption2)
            }
        }
        .frame(width: 50)
    }

    @ViewBuilder
    private func workoutContent(_ workout: ClientDayWorkout) -> some View {
        if let imgUrl = workout.img_url, let url = URL(string: imgUrl) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 36, height: 36)
                    .cornerRadius(6)
            } placeholder: {
                Color.gray.opacity(0.3)
                    .frame(width: 36, height: 36)
                    .cornerRadius(6)
            }
        }

        VStack(alignment: .leading, spacing: 1) {
            Text(workout.title ?? "Workout")
                .font(.caption2)
                .foregroundColor(.white)
                .lineLimit(1)
            HStack(spacing: 6) {
                if let time = workout.total_minutes {
                    Text("\(time)m")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                if let cal = workout.calories {
                    Text("\(Int(cal))cal")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }
        }
    }

    private var rowBackground: Color {
        if isDone { return Color.green.opacity(0.08) }
        if isRest { return Color.yellow.opacity(0.06) }
        return Color.gray.opacity(0.08)
    }
}
