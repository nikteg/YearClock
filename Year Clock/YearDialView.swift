//
//  YearDialView.swift
//  Year Clock
//
//  Created by Assistant on 2025-09-14.
//

import SwiftUI

/// A radial dial that represents the year split into months, grouped by season.
/// - Design notes:
///   - Spring is on the right, Fall is on the left.
///   - Months advance clockwise.
///   - Uses English initials for months.
struct YearDialView: View {
    /// For previews/testing: when set, the dial uses this date instead of `.now`.
    var overrideDate: Date? = nil

    /// Global rotation applied to the month ring and separators (degrees).
    /// Negative values rotate left (counterclockwise).
    private let rotationOffsetDegrees: Double = -45.0
    struct MonthSlice: Identifiable {
        let id: Int
        let name: String
        let startAngle: Angle
        let endAngle: Angle
        let color: Color
    }

    /// Colors for seasons (Spring, Summer, Fall, Winter)
    private let seasonColors: [Color] = [
        Color(hue: 0.35, saturation: 0.65, brightness: 0.75), // Spring - green
        Color(hue: 0.12, saturation: 0.70, brightness: 0.80), // Summer - yellow/olive
        Color(hue: 0.09, saturation: 0.65, brightness: 0.70), // Fall - orange/brown
        Color(hue: 0.60, saturation: 0.45, brightness: 0.70)  // Winter - blue
    ]

    /// Month labels (3-letter English abbreviations)
    private let monthInitials = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]

    /// Month to season index mapping (0:Spring, 1:Summer, 2:Fall, 3:Winter)
    /// Jan, Feb -> Winter; Mar, Apr, May -> Spring; Jun, Jul, Aug -> Summer; Sep, Oct, Nov -> Fall; Dec -> Winter
    private let monthToSeason: [Int] = [3,3,0,0,0,1,1,1,2,2,2,3]

    /// Build slices so that Spring (Mar) is centered on the right, Fall (Sep) on the left.
    /// We will place March at angle 0° (pointing right), and progress clockwise.
    private func buildSlices(rect: CGRect) -> [MonthSlice] {
        // 12 equal slices across 360 degrees, starting at March on the right.
        // Angle 0 is east. SwiftUI 0 degrees is to the right when using standard polar transforms.
        // We'll define startAngle at -15 deg from month center so that labels center nicely.
        let degreesPerMonth: Double = 360.0 / 12.0

        var slices: [MonthSlice] = []
        // Month index: 0..11 for Jan..Dec
        for monthIndex in 0..<12 {
            // Map month index to dial index where March is index 0 on the right.
            // dialIndex 0 -> March (month 2), 1 -> April (3), ..., 9 -> January (0), 10 -> February (1)
            let dialIndex: Int
            if monthIndex >= 2 {
                dialIndex = monthIndex - 2
            } else {
                dialIndex = monthIndex + 10
            }

            let startDeg = Double(dialIndex) * degreesPerMonth + rotationOffsetDegrees
            let endDeg = startDeg + degreesPerMonth
            let seasonIndex = monthToSeason[monthIndex]

            let slice = MonthSlice(
                id: monthIndex,
                name: monthInitials[monthIndex],
                startAngle: .degrees(startDeg),
                endAngle: .degrees(endDeg),
                color: seasonColors[seasonIndex]
            )
            slices.append(slice)
        }
        return slices
    }

    var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)
            let rect = CGRect(x: 0, y: 0, width: size, height: size)
            let radius = size / 2.0
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let ringThickness = size * 0.16
            let labelRadius = radius - ringThickness * 1.2
            let pointerLength = radius * 0.82
            let hubRadius = size * 0.06
            let pointerWidth = size * 0.055

            let now = overrideDate ?? Date()
            let pointerTargetAngleFromEast = angleForMonthCenter(now)

            ZStack {
                // Outer subtle tick ring
                Circle()
                    .stroke(Color.secondary.opacity(0.25), lineWidth: ringThickness * 0.25)

                // Month wedges
                ForEach(buildSlices(rect: rect)) { slice in
                    SliceShape(startAngle: slice.startAngle, endAngle: slice.endAngle)
                        .fill(slice.color)
                }

                // Month separators
                ForEach(0..<12, id: \.self) { i in
                    let angle = Angle.degrees(Double(i) * 30.0 - 45.0)
                    Capsule()
                        .fill(Color.black.opacity(0.15))
                        .frame(width: 1.0, height: radius)
                        .offset(x: 0, y: -radius/2)
                        .rotationEffect(angle)
                }

                // Labels
                ForEach(buildSlices(rect: rect)) { slice in
                    let centerAngle = Angle.degrees((slice.startAngle.degrees + slice.endAngle.degrees) / 2.0)
                    Text(slice.name)
                        .font(.system(size: size * 0.09, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.9))
                        .position(point(on: center, radius: labelRadius, angle: centerAngle))
                }

                // Pointer
                Capsule()
                    .fill(Color.white)
                    .frame(width: pointerWidth, height: pointerLength)
                    .offset(x: 0, y: -pointerLength/2)
                    .shadow(color: Color.black.opacity(0.25), radius: 2, x: 0, y: 1)
                    // Base orientation points up (north). Convert absolute dial angle (0=east) to view rotation.
                    .rotationEffect(pointerTargetAngleFromEast + .degrees(-90))

                // Hub
                Circle()
                    .fill(Color.white)
                    .frame(width: hubRadius * 2, height: hubRadius * 2)
                    .overlay(
                        Circle().stroke(Color.black.opacity(0.1), lineWidth: 1)
                    )
            }
            .frame(width: size, height: size)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func point(on center: CGPoint, radius: CGFloat, angle: Angle) -> CGPoint {
        let radians = angle.radians
        let x = center.x + cos(radians) * radius
        let y = center.y + sin(radians) * radius
        return CGPoint(x: x, y: y)
    }
}

/// A pie-slice shape using start and end angles measured clockwise from the positive X axis (to the right).
private struct SliceShape: Shape {
    var startAngle: Angle
    var endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2.0

        path.move(to: center)
        path.addArc(center: center,
                    radius: radius,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false)
        path.closeSubpath()
        return path
    }
}

// MARK: - Year math

extension YearDialView {
    /// Returns the angle for the current date where 0° points to March 1 at 00:00 local time.
    /// Advances clockwise through the year.
    func angleForDate(_ date: Date) -> Angle {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: date)
        guard let year = components.year else { return .degrees(0) }

        // Define the anchor at March 1st of this year, local midnight
        let marchStartComponents = DateComponents(year: year, month: 3, day: 1)
        guard let marchStart = calendar.date(from: marchStartComponents) else { return .degrees(0) }

        // Determine start of next year March 1 for duration; if date is before March 1, use previous year anchor
        var anchor = marchStart
        if date < marchStart {
            let prev = DateComponents(year: year - 1, month: 3, day: 1)
            anchor = calendar.date(from: prev) ?? marchStart
        }

        let nextAnchorComponents = DateComponents(year: calendar.component(.year, from: anchor) + 1, month: 3, day: 1)
        let nextAnchor = calendar.date(from: nextAnchorComponents) ?? anchor.addingTimeInterval(365*24*3600)

        let total = nextAnchor.timeIntervalSince(anchor)
        let elapsed = date.timeIntervalSince(anchor)
        let progress = max(0, min(1, elapsed / total))

        // Map progress to degrees (0..360). March (anchor) is 0° on the right.
        return .degrees(progress * 360.0)
    }

    /// Returns the absolute dial angle (0° = pointing right/east) for the center of the current month,
    /// respecting the dial's rotation and month ordering (Mar at 0°).
    func angleForMonthCenter(_ date: Date) -> Angle {
        let calendar = Calendar.current
        // month: 1..12 for Jan..Dec
        let monthIndex = (calendar.component(.month, from: date) - 1) // 0-based

        // Map to dial index where 0 = March
        let dialIndex: Int
        if monthIndex >= 2 {
            dialIndex = monthIndex - 2
        } else {
            dialIndex = monthIndex + 10
        }

        let degreesPerMonth: Double = 360.0 / 12.0
        let angle = Double(dialIndex) * degreesPerMonth + rotationOffsetDegrees + degreesPerMonth / 2.0
        return .degrees(angle)
    }
}

#if DEBUG
struct YearDialView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            YearDialView(overrideDate: Calendar.current.date(from: DateComponents(year: 2025, month: 3, day: 1)))
                .frame(width: 220, height: 220)
                .previewDisplayName("March (Spring)")

            YearDialView(overrideDate: Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 1)))
                .frame(width: 220, height: 220)
                .previewDisplayName("September (Fall)")

            YearDialView(overrideDate: Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 1)))
                .frame(width: 220, height: 220)
                .previewDisplayName("December (Winter)")
        }
    }
}
#endif


