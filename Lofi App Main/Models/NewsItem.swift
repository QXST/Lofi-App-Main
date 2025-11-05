//
//  NewsItem.swift
//  Lofi App Main
//
//  Created by Quest on 11/4/25.
//

import Foundation

struct NewsItem: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let imageURL: String?
    let date: Date
    let relativeTime: String

    init(
        id: UUID = UUID(),
        title: String,
        description: String = "",
        imageURL: String? = nil,
        date: Date = Date(),
        relativeTime: String
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.imageURL = imageURL
        self.date = date
        self.relativeTime = relativeTime
    }
}

extension NewsItem {
    static let sampleNews: [NewsItem] = [
        NewsItem(
            title: "Lo-fi Clouds mixes on youtube.",
            description: "Check out our latest curated mixes",
            imageURL: "https://picsum.photos/160/90?random=1",
            relativeTime: "24 days ago"
        ),
        NewsItem(
            title: "KF13 is back!",
            description: "New album release from KF13",
            imageURL: "https://picsum.photos/160/90?random=2",
            relativeTime: "8 months ago"
        ),
        NewsItem(
            title: "Welcome London-based guitarist Koikid",
            description: "New artist spotlight",
            imageURL: "https://picsum.photos/160/90?random=3",
            relativeTime: "9 months ago"
        ),
        NewsItem(
            title: "Label debut by Japanese producer kf13",
            description: "First release on our label",
            imageURL: "https://picsum.photos/160/90?random=4",
            relativeTime: "10 months ago"
        ),
        NewsItem(
            title: "Zforms' 4th ambient single is out!",
            description: "New single available now",
            imageURL: "https://picsum.photos/160/90?random=5",
            relativeTime: "11 months ago"
        )
    ]
}
