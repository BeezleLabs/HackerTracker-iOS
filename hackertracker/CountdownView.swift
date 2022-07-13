//
//  Countdown.swift
//  hackertracker
//
//  Created by caleb on 7/13/22.
//  Copyright © 2022 Beezle Labs. All rights reserved.
//

import Foundation
import SwiftUI

struct Countdown: View {
    let start: Date
    @State private var countdownTimer: CountdownComps?

    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("\(countdownTimer?.days ?? 0)").font(.largeTitle).foregroundColor(ThemeColors.pink)
                Text("days").font(.caption)
            }

            HStack {
                Text("\(countdownTimer?.hours ?? 0)").font(.largeTitle).foregroundColor(ThemeColors.blue)
                Text("hours").font(.caption)
            }

            HStack {
                Text("\(countdownTimer?.minutes ?? 0)").font(.largeTitle).foregroundColor(ThemeColors.green)
                Text("min").font(.caption)
            }

            HStack {
                Text("\(countdownTimer?.seconds ?? 0)").font(.largeTitle).foregroundColor(ThemeColors.red)
                Text("sec").font(.caption)
            }
        }
        .onAppear {
            countdownTimer = CountdownComps(days: 0, hours: 0, minutes: 0, seconds: 0)
        }
        .onReceive(timer) { _ in
            withAnimation {
                countdownTimer = getCountdown(start: start)
            }
        }
    }
}

struct CountdownComps {
    var days: Int
    var hours: Int
    var minutes: Int
    var seconds: Int
}

func getCountdown(start: Date) -> CountdownComps {
    let timeUntilConfStart = start.timeIntervalSinceNow
    let day = timeUntilConfStart / (24 * 60 * 60)
    let hour = day.truncatingRemainder(dividingBy: 1) * 24
    let min = hour.truncatingRemainder(dividingBy: 1) * 60
    let sec = min.truncatingRemainder(dividingBy: 1) * 60

    return CountdownComps(
        days: Int(day.rounded(.down)),
        hours: Int(hour.rounded(.down)),
        minutes: Int(min.rounded(.down)),
        seconds: Int(sec.rounded(.down))
    )
}

struct Countdown_Previews: PreviewProvider {
    static var previews: some View {
        Countdown(start: getPreviewStart())
    }
}

func getPreviewStart() -> Date {
    let newFormatter = ISO8601DateFormatter()
    let date = newFormatter.date(from: "2022-08-11T00:00:00-0700")
    return date ?? Date()
}
