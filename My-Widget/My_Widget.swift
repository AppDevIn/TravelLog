//
//  TraveLogWidget.swift
//  TraveLogWidget
//
//  Created by Jeya Vishnu on 1/2/21.
//

import WidgetKit
import SwiftUI
import Intents


struct LocationEntry:TimelineEntry {
    var date: Date = Date()
    let Location: String
}

struct Provider: TimelineProvider {
    
    
    @AppStorage("location", store: UserDefaults(suiteName: "group.sg.mad2.TravelLog"))
    var location: String = ""

    func placeholder(in context: Context) -> LocationEntry {
        LocationEntry(date: Date(), Location: "Location")
    }
    
    func getSnapshot(in context: Context, completion: @escaping (LocationEntry) -> Void) {
        let entry = LocationEntry(Location: location)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<LocationEntry>) -> Void) {
        
        let entry = LocationEntry(Location: location)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        
        completion(timeline)
    }
    



}


struct TraveLogWidgetEntryView : View {
    var entry: Provider.Entry
    
    
    
    var body: some View {
        VStack(alignment: .center, spacing: 20, content: {
            HStack(alignment: .center, spacing: 20, content: {
                
                Text(entry.Location)
                    .frame(maxWidth: .infinity, alignment: .leading) // << full width
                    .padding()
                    .multilineTextAlignment(.center)
                    
            })
           
        })
    }
}

@main
struct TraveLogWidget: Widget {
    let kind: String = "TraveLogWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind,
                            provider: Provider()) { entry in
            TraveLogWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct TraveLogWidget_Previews: PreviewProvider {
    static var previews: some View {
        
        TraveLogWidgetEntryView(entry:LocationEntry(Location: "dsjflksdjfjskdjkjjsfdkjjkjhfgjhsfjkhgjfsdh")).previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
