//
//  ilumoreWidgetLiveActivity.swift
//  ilumoreWidget
//
//  Created by Love, Su Lei on 6/5/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct ilumoreWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct ilumoreWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ilumoreWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension ilumoreWidgetAttributes {
    fileprivate static var preview: ilumoreWidgetAttributes {
        ilumoreWidgetAttributes(name: "World")
    }
}

extension ilumoreWidgetAttributes.ContentState {
    fileprivate static var smiley: ilumoreWidgetAttributes.ContentState {
        ilumoreWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: ilumoreWidgetAttributes.ContentState {
         ilumoreWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: ilumoreWidgetAttributes.preview) {
   ilumoreWidgetLiveActivity()
} contentStates: {
    ilumoreWidgetAttributes.ContentState.smiley
    ilumoreWidgetAttributes.ContentState.starEyes
}
