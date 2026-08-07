import AppIntents
import SwiftUI
import WidgetKit

// MARK: - AppIntent

struct CheckInIntent: AppIntent {
    static var title: LocalizedStringResource = "Valider une habitude"

    @Parameter(title: "Habit ID")
    var habitId: Int

    init() { habitId = 0 }
    init(habitId: Int) { self.habitId = habitId }

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.fr.flexiflow.morpho")

        // Optimistic UI update — mark as done in widget_data before Flutter syncs
        optimisticallyMarkDone(defaults: defaults)

        // Append to pending queue so Flutter processes it on next foreground
        enqueuePending(defaults: defaults)

        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }

    private func optimisticallyMarkDone(defaults: UserDefaults?) {
        guard
            let json = defaults?.string(forKey: "widget_data"),
            let data = json.data(using: .utf8),
            var root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            var habits = root["habits"] as? [[String: Any]]
        else { return }

        for i in 0..<habits.count {
            if let id = habits[i]["id"] as? Int, id == habitId {
                habits[i]["done"] = true
                break
            }
        }
        root["habits"] = habits
        root["done"] = habits.filter { $0["done"] as? Bool == true }.count

        if let updated = try? JSONSerialization.data(withJSONObject: root),
           let updatedJson = String(data: updated, encoding: .utf8)
        {
            defaults?.set(updatedJson, forKey: "widget_data")
        }
    }

    private func enqueuePending(defaults: UserDefaults?) {
        let current = defaults?.string(forKey: "pending_checkins") ?? "[]"
        guard
            let data = current.data(using: .utf8),
            var ids = try? JSONDecoder().decode([Int].self, from: data),
            !ids.contains(habitId)
        else { return }

        ids.append(habitId)
        if let encoded = try? JSONEncoder().encode(ids),
           let json = String(data: encoded, encoding: .utf8)
        {
            defaults?.set(json, forKey: "pending_checkins")
        }
    }
}

// MARK: - Data Models

struct HabitItem: Identifiable {
    let id: Int
    let name: String
    let streak: Int
    let done: Bool
    let plant: String
}

struct WidgetSnapshot {
    let done: Int
    let total: Int
    let habits: [HabitItem]
}

// MARK: - Parsing

private func loadSnapshot() -> WidgetSnapshot? {
    guard
        let defaults = UserDefaults(suiteName: "group.fr.flexiflow.morpho"),
        let json = defaults.string(forKey: "widget_data"),
        let data = json.data(using: .utf8),
        let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    else { return nil }

    let done = root["done"] as? Int ?? 0
    let total = root["total"] as? Int ?? 0
    let rawHabits = root["habits"] as? [[String: Any]] ?? []

    let habits = rawHabits.enumerated().map { idx, h -> HabitItem in
        HabitItem(
            id: h["id"] as? Int ?? idx,
            name: h["name"] as? String ?? "",
            streak: h["streak"] as? Int ?? 0,
            done: h["done"] as? Bool ?? false,
            plant: h["plant"] as? String ?? "🌱"
        )
    }

    return WidgetSnapshot(done: done, total: total, habits: habits)
}

// MARK: - Timeline Entry

struct MorphoEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot?
}

// MARK: - Provider

struct MorphoProvider: TimelineProvider {
    func placeholder(in context: Context) -> MorphoEntry {
        MorphoEntry(date: Date(), snapshot: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (MorphoEntry) -> Void) {
        completion(MorphoEntry(date: Date(), snapshot: loadSnapshot()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MorphoEntry>) -> Void) {
        let entry = MorphoEntry(date: Date(), snapshot: loadSnapshot())
        let midnight = Calendar.current.startOfDay(for: Date().addingTimeInterval(86_400))
        completion(Timeline(entries: [entry], policy: .after(midnight)))
    }
}

// MARK: - Design tokens

private extension Color {
    static let morphoBg     = Color(red: 0.106, green: 0.263, blue: 0.196)
    static let morphoAccent = Color(red: 0.455, green: 0.776, blue: 0.616)
    static let morphoLabel  = Color.white
    static let morphoMuted  = Color.white.opacity(0.55)
}

// MARK: - Small widget (display-only)

private struct SmallView: View {
    let snap: WidgetSnapshot

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            (
                Text("\(snap.done)")
                    .font(.system(size: 46, weight: .bold, design: .rounded))
                    .foregroundColor(.morphoLabel)
                + Text("/\(snap.total)")
                    .font(.system(size: 22, weight: .medium, design: .rounded))
                    .foregroundColor(.morphoMuted)
            )
            Text("aujourd'hui")
                .font(.system(size: 11, weight: .medium))
                .tracking(1.5)
                .foregroundColor(.morphoMuted)
                .padding(.top, 2)
            Spacer()
            HStack(spacing: 4) {
                ForEach(Array(snap.habits.prefix(4)), id: \.id) { h in
                    Text(h.plant)
                        .font(.system(size: 20))
                        .opacity(h.done ? 1.0 : 0.35)
                }
            }
            .padding(.bottom, 14)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.morphoBg)
    }
}

// MARK: - Medium widget (interactive)

private struct MediumView: View {
    let snap: WidgetSnapshot

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            // Left — daily score
            VStack(alignment: .leading, spacing: 4) {
                Text("morpho")
                    .font(.system(size: 10, weight: .light))
                    .tracking(3)
                    .foregroundColor(.morphoMuted)

                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(snap.done)")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.morphoLabel)
                    Text("/\(snap.total)")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundColor(.morphoMuted)
                }

                Text("habitudes\naujourd'hui")
                    .font(.system(size: 11))
                    .foregroundColor(.morphoMuted)
                    .lineLimit(2)
            }
            .padding(.leading, 18)
            .frame(maxWidth: .infinity, alignment: .leading)

            Rectangle()
                .fill(Color.white.opacity(0.12))
                .frame(width: 1)
                .padding(.vertical, 18)

            // Right — interactive habit list
            VStack(alignment: .leading, spacing: 2) {
                ForEach(Array(snap.habits.prefix(4)), id: \.id) { h in
                    InteractiveHabitRow(habit: h)
                }
            }
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.morphoBg)
    }
}

private struct InteractiveHabitRow: View {
    let habit: HabitItem

    var body: some View {
        Button(intent: CheckInIntent(habitId: habit.id)) {
            HStack(spacing: 6) {
                Text(habit.plant)
                    .font(.system(size: 18))
                    .opacity(habit.done ? 1.0 : 0.4)

                VStack(alignment: .leading, spacing: 0) {
                    Text(habit.name)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.morphoLabel)
                        .lineLimit(1)

                    if habit.streak > 0 {
                        Text("\(habit.streak)j 🔥")
                            .font(.system(size: 10))
                            .foregroundColor(.morphoMuted)
                    }
                }

                Spacer()

                Image(systemName: habit.done ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 16))
                    .foregroundColor(habit.done ? .morphoAccent : .morphoMuted)
            }
            .padding(.vertical, 5)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(habit.done)
    }
}

// MARK: - Placeholder

private struct PlaceholderView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("🌱")
                .font(.system(size: 40))
            Text("morpho")
                .font(.system(size: 12, weight: .light))
                .tracking(3)
                .foregroundColor(.morphoMuted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.morphoBg)
    }
}

// MARK: - Entry view

struct MorphoEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: MorphoEntry

    var body: some View {
        if let snap = entry.snapshot, snap.total > 0 {
            switch family {
            case .systemMedium:
                MediumView(snap: snap)
            default:
                SmallView(snap: snap)
            }
        } else {
            PlaceholderView()
        }
    }
}

// MARK: - Widget

@main
struct MorphoWidget: Widget {
    let kind: String = "MorphoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MorphoProvider()) { entry in
            MorphoEntryView(entry: entry)
                .containerBackground(Color.morphoBg, for: .widget)
        }
        .configurationDisplayName("morpho")
        .description("Tes habitudes du jour")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
