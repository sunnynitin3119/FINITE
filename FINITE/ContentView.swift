import SwiftUI
import UIKit

struct ContentView: View {
    @AppStorage("completedDays") private var completedDays = 0
    @State private var showingResetConfirmation = false

    private let totalDays = 365
    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 10),
        count: 7
    )

    private var remainingDays: Int {
        max(totalDays - completedDays, 0)
    }

    private var progress: Double {
        Double(completedDays) / Double(totalDays)
    }

    private var progressLabel: String {
        progress.formatted(.percent.precision(.fractionLength(0)))
    }

    var body: some View {
        ZStack {
            Color.finiteBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    header
                    progressCard
                    yearGrid
                    actionArea
                }
                .padding(.horizontal, 22)
                .padding(.top, 14)
                .padding(.bottom, 36)
            }
            .scrollIndicators(.hidden)
        }
        .preferredColorScheme(.dark)
        .confirmationDialog(
            "Reset your year?",
            isPresented: $showingResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("Reset all progress", role: .destructive) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    completedDays = 0
                }
            }
        } message: {
            Text("This will mark every day as incomplete.")
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 5) {
                Text("FINITE")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .tracking(3)
                    .foregroundStyle(Color.finiteAccent)

                Text("Make today count.")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }

            Spacer()

            Menu {
                if completedDays > 0 {
                    Button {
                        withAnimation(.easeOut(duration: 0.2)) {
                            completedDays -= 1
                        }
                    } label: {
                        Label("Undo last day", systemImage: "arrow.uturn.backward")
                    }
                }

                Button(role: .destructive) {
                    showingResetConfirmation = true
                } label: {
                    Label("Reset progress", systemImage: "arrow.counterclockwise")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(Color.white.opacity(0.08), in: Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.08)))
            }
            .accessibilityLabel("Progress options")
        }
    }

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("\(remainingDays)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())

                    Text("days still yours")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.finiteSecondary)
                }

                Spacer()

                Text(progressLabel)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.finiteAccent)
                    .padding(.horizontal, 13)
                    .padding(.vertical, 8)
                    .background(Color.finiteAccent.opacity(0.12), in: Capsule())
            }

            ProgressView(value: progress)
                .tint(Color.finiteAccent)
                .scaleEffect(x: 1, y: 1.6, anchor: .center)

            HStack {
                Label("\(completedDays) lived", systemImage: "checkmark.circle.fill")
                Spacer()
                Text("\(totalDays) day journey")
            }
            .font(.caption.weight(.medium))
            .foregroundStyle(Color.finiteSecondary)
        }
        .padding(22)
        .background(
            LinearGradient(
                colors: [Color.finiteCard, Color.finiteCard.opacity(0.74)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.07))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(completedDays) days complete, \(remainingDays) days remaining, \(progressLabel)")
    }

    private var yearGrid: some View {
        VStack(alignment: .leading, spacing: 17) {
            HStack {
                Text("YOUR YEAR")
                    .font(.caption.weight(.bold))
                    .tracking(1.6)
                    .foregroundStyle(Color.finiteSecondary)

                Spacer()

                HStack(spacing: 14) {
                    legendDot(color: Color.finiteAccent, label: "Lived")
                    legendDot(color: Color.white.opacity(0.12), label: "Ahead")
                }
            }

            LazyVGrid(columns: columns, spacing: 11) {
                ForEach(0..<totalDays, id: \.self) { index in
                    Circle()
                        .fill(index < completedDays ? Color.finiteAccent : Color.white.opacity(0.11))
                        .frame(width: 13, height: 13)
                        .overlay {
                            if index == completedDays {
                                Circle()
                                    .stroke(Color.finiteAccent.opacity(0.55), lineWidth: 2)
                                    .frame(width: 21, height: 21)
                            }
                        }
                        .animation(.easeOut(duration: 0.2), value: completedDays)
                        .accessibilityLabel("Day \(index + 1)")
                        .accessibilityValue(index < completedDays ? "Complete" : "Not complete")
                }
            }
            .padding(20)
            .background(Color.finiteCard.opacity(0.56), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.white.opacity(0.06))
            )
        }
    }

    private var actionArea: some View {
        VStack(spacing: 12) {
            Button {
                guard completedDays < totalDays else { return }

                withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                    completedDays += 1
                }
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            } label: {
                HStack {
                    Image(systemName: completedDays == totalDays ? "checkmark.seal.fill" : "checkmark")
                    Text(completedDays == totalDays ? "Year complete" : "I made today count")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .foregroundStyle(Color.finiteBackground)
                .background(Color.finiteAccent, in: RoundedRectangle(cornerRadius: 17, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(completedDays == totalDays)
            .accessibilityHint("Marks the next day in your year as complete")

            Text("One tap. One day. Progress is stored privately on this device.")
                .font(.caption)
                .foregroundStyle(Color.finiteSecondary)
                .multilineTextAlignment(.center)
        }
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: 7, height: 7)
            Text(label)
        }
        .font(.caption2.weight(.medium))
        .foregroundStyle(Color.finiteSecondary)
    }
}

private extension Color {
    static let finiteBackground = Color(red: 0.035, green: 0.045, blue: 0.07)
    static let finiteCard = Color(red: 0.075, green: 0.09, blue: 0.135)
    static let finiteAccent = Color(red: 0.37, green: 0.91, blue: 0.68)
    static let finiteSecondary = Color.white.opacity(0.54)
}

#Preview {
    ContentView()
}
