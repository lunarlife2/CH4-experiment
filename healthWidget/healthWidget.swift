import WidgetKit
import SwiftUI
import HealthKit


struct HealthEntry: TimelineEntry {
    let date: Date
    let steps: Int
    let stepsGoal: Int
    let calories: Double
    let caloriesGoal: Double
    let permissionGranted: Bool
}

extension HealthEntry {
    static let placeholder = HealthEntry(
        date: .now,
        steps: 8240,
        stepsGoal: 10000,
        calories: 612,
        caloriesGoal: 750,
        permissionGranted: true
    )
}

struct HealthDataFetcher {

    static let shared = HealthDataFetcher()
    private let healthStore = HKHealthStore()

    func fetchTodayEntry() async -> HealthEntry {
        guard HKHealthStore.isHealthDataAvailable() else {
            return HealthEntry(
                date: .now, steps: 0, stepsGoal: 10000,
                calories: 0, caloriesGoal: 750, permissionGranted: false
            )
        }
        async let steps = fetchTodaySteps()
        async let calories = fetchTodayCalories()
        let (stepsValue, caloriesValue) = await (steps, calories)

        return HealthEntry(
            date: .now,
            steps: stepsValue,
            stepsGoal: 10000,
            calories: caloriesValue,
            caloriesGoal: 750,
            permissionGranted: true
        )
    }

    private func fetchTodaySteps() async -> Int {
        let stepType = HKQuantityType(.stepCount)
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)

        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )

        let descriptor = HKStatisticsQueryDescriptor(
            predicate: .quantitySample(type: stepType, predicate: predicate),
            options: .cumulativeSum
        )

        do {
            let result = try await descriptor.result(for: healthStore)
            if let sum = result?.sumQuantity() {
                return Int(sum.doubleValue(for: .count()))
            }
        } catch {
            print("Widget step query failed: \(error.localizedDescription)")
        }
        return 0
    }

    private func fetchTodayCalories() async -> Double {
        let energyType = HKQuantityType(.activeEnergyBurned)
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)

        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )

        let descriptor = HKStatisticsQueryDescriptor(
            predicate: .quantitySample(type: energyType, predicate: predicate),
            options: .cumulativeSum
        )

        do {
            let result = try await descriptor.result(for: healthStore)
            if let sum = result?.sumQuantity() {
                return sum.doubleValue(for: .kilocalorie())
            }
        } catch {
            print("Widget calories query failed: \(error.localizedDescription)")
        }
        return 0
    }
}


struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> HealthEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (HealthEntry) -> Void) {
        if context.isPreview {
            completion(.placeholder)
            return
        }
        Task {
            completion(await HealthDataFetcher.shared.fetchTodayEntry())
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HealthEntry>) -> Void) {
        Task {
            let entry = await HealthDataFetcher.shared.fetchTodayEntry()
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: .now) ?? .now
            completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
        }
    }
}

private func formattedSteps(_ steps: Int) -> String {
    steps.formatted(.number.grouping(.automatic))
}

private func formattedCalories(_ cal: Double) -> String {
    cal.formatted(.number.precision(.fractionLength(0)))
}

struct SmallHealthView: View {
    let entry: HealthEntry

    private var progress: Double {
        guard entry.stepsGoal > 0 else { return 0 }
        return min(Double(entry.steps) / Double(entry.stepsGoal), 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "figure.walk")
                    .font(.system(size: 18))
                    .foregroundStyle(.blue)
                Spacer()
                Text("Today")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(formattedSteps(entry.steps))
                    .font(.system(size: 26, weight: .semibold))
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                Text("Steps")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            ProgressView(value: progress)
                .tint(.blue)
        }
        .padding(14)
    }
}


struct MediumHealthView: View {
    let entry: HealthEntry

    var body: some View {
        HStack(spacing: 0) {
            metricColumn(
                icon: "figure.walk",
                iconColor: .blue,
                label: "Steps",
                value: formattedSteps(entry.steps),
                caption: "Goal \(formattedSteps(entry.stepsGoal))"
            )

            Divider()
                .padding(.horizontal, 16)

            metricColumn(
                icon: "flame.fill",
                iconColor: .red,
                label: "Calories",
                value: formattedCalories(entry.calories),
                caption: "kcal today"
            )
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
    }

    private func metricColumn(icon: String, iconColor: Color, label: String, value: String, caption: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(iconColor)
                Text(label)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            Text(value)
                .font(.system(size: 22, weight: .semibold))
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            Text(caption)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}


struct LargeHealthView: View {
    let entry: HealthEntry

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Text("Health")
                    .font(.system(size: 13, weight: .semibold))
                Spacer()
                Text(entry.date, style: .time)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }

            ringCard(
                icon: "figure.walk",
                iconColor: .blue,
                label: "Steps",
                value: formattedSteps(entry.steps),
                unit: nil,
                progress: min(Double(entry.steps) / Double(max(entry.stepsGoal, 1)), 1),
                ringColor: .blue
            )

            ringCard(
                icon: "flame.fill",
                iconColor: .red,
                label: "Active calories",
                value: formattedCalories(entry.calories),
                unit: "kcal",
                progress: min(entry.calories / max(entry.caloriesGoal, 1), 1),
                ringColor: .red
            )

            HStack {
                Text(entry.permissionGranted ? "Permission granted" : "Permission needed")
                    .font(.system(size: 10, weight: .medium))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        (entry.permissionGranted ? Color.green : Color.orange).opacity(0.15)
                    )
                    .foregroundStyle(entry.permissionGranted ? .green : .orange)
                    .clipShape(Capsule())
                Spacer()
            }
        }
        .padding(18)
    }

    private func ringCard(icon: String, iconColor: Color, label: String, value: String, unit: String?, progress: Double, ringColor: Color) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundStyle(iconColor)
                    Text(label)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.system(size: 24, weight: .semibold))
                    if let unit {
                        Text(unit)
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            Spacer()
            ZStack {
                Circle()
                    .stroke(ringColor.opacity(0.15), lineWidth: 5)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(ringColor, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(ringColor)
            }
            .frame(width: 48, height: 48)
        }
        .padding(14)
        .background(Color(.tertiarySystemFill).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct healthWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: HealthEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallHealthView(entry: entry)
        case .systemMedium:
            MediumHealthView(entry: entry)
        case .systemLarge:
            LargeHealthView(entry: entry)
        default:
            SmallHealthView(entry: entry)
        }
    }
}


struct healthWidget: Widget {
    let kind: String = "healthWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            healthWidgetEntryView(entry: entry)
                .containerBackground(.background, for: .widget)
        }
        .configurationDisplayName("Health")
        .description("Today's steps and active calories.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview("Small", as: .systemSmall) {
    healthWidget()
} timeline: {
    HealthEntry.placeholder
}

#Preview("Medium", as: .systemMedium) {
    healthWidget()
} timeline: {
    HealthEntry.placeholder
}

#Preview("Large", as: .systemLarge) {
    healthWidget()
} timeline: {
    HealthEntry.placeholder
}
