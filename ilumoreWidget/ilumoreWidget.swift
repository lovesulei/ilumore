//
//  ilumoreWidget.swift
//  ilumoreWidget
//
//  Created by Love, Su Lei on 6/5/25.
//

import WidgetKit
import SwiftUI

struct LoveEntry: TimelineEntry {
    let date: Date
    let yourCount: Int
    let partnerCount: Int
    let yourColor: String     // "black" or "orange"
    let partnerColor: String  // "black" or "orange"
    let winner: String
}

struct Provider: TimelineProvider {
    typealias Entry = LoveEntry
    
    func placeholder(in context: Context) -> Entry {
       LoveEntry(date: Date(), yourCount: 0, partnerCount: 0, yourColor: "black", partnerColor: "orange", winner: "Who loves more?")
    }

    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        let entry = LoveEntry(date: Date(), yourCount: 5, partnerCount: 12, yourColor: "black", partnerColor: "orange", winner: "Tester 2 wins today")
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        
        let defaults = UserDefaults(suiteName: "group.com.lovesulei.ilumore")
        
        // take this from app group
        
        let yourCount = defaults?.integer(forKey: "yourCount") ?? 0
        let partnerCount = defaults?.integer(forKey: "partnerCount") ?? 0
        let yourColor = defaults?.string(forKey: "yourColor") ?? "black"
        let partnerColor = defaults?.string(forKey: "partnerColor") ?? "orange"
        let winner = defaults?.string(forKey: "winnerText") ?? "Who loves more?"
        
        let entry = LoveEntry (date: Date(), yourCount: yourCount, partnerCount: partnerCount, yourColor: yourColor, partnerColor: partnerColor, winner: winner)
        
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(15 * 60)))
        completion(timeline)
    }
}


struct ilumoreWidgetEntryView : View {
    var entry: Provider.Entry
    private let dailyTarget = 50
    
    private func progressPercent(for count: Int) -> Double {
        let percent = (Double(count) / Double(dailyTarget)) * 100
        return min(percent, 100)
    }
    
    private func heartImageSuffix(for percentComplete: Double) -> String {
        switch percentComplete {
            case 0..<50: return "25"
            case 50..<75: return "50"
            case 75..<100: return "100"
            default: return "100"
        }
        }
    
    
    var body: some View {
        // which count belongs to black/orange
        let blackCount  = (entry.yourColor == "black")
            ? entry.yourCount
            : entry.partnerCount
        let orangeCount = (entry.yourColor == "orange")
            ? entry.yourCount
            : entry.partnerCount
        
        // set up image file path
        let blackPercent   = progressPercent(for: blackCount)
        let blackSuffix    = heartImageSuffix(for: blackPercent)
        let blackImageName = "black_\(blackSuffix)"   // e.g. "black_50"

        let orangePercent   = progressPercent(for: orangeCount)
        let orangeSuffix    = heartImageSuffix(for: orangePercent)
        let orangeImageName = "orange_\(orangeSuffix)" // e.g. "orange_75"
        
        return VStack(spacing: 3) {
            HStack {
                Spacer()
                Image("heart_pixel")
                    .frame(width: 15, height: 15)
                Text(entry.winner)
                    .font(.custom("PixelifySans-Medium", size: 18))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .padding(.bottom, 4)
                Image("heart_pixel")
                    .frame(width: 15, height: 15)
                Spacer()
            }
            HStack {
                HStack (spacing: 12) { // makes sure the black and orange cat in right places
                    Text("\(blackCount)")
                        .font(.custom("PixelifySans-Medium", size: 16))
                    Image(blackImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                   
                }
                HStack (spacing: 12) { // makes sure the black and orange cat in right places
                    Image(orangeImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                    Text("\(orangeCount)")
                        .font(.custom("PixelifySans-Medium", size: 16))
                }
            }.padding(.horizontal, 2)
        }
        .padding()
        .containerBackground(for: .widget) {
            Image("day_bg")
                .resizable()
                .scaledToFill()
        }
    }
       
}

@main
struct ilumoreWidget: Widget {
    let kind: String = "ILUMoreWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ilumoreWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("ILYMore Widget")
        .description("Shows today's love tap counts and winner!")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

