//
//  File.swift
//  IOS-Project
//
//  Created by Warre Descamps on 09/12/2022.
//

import Foundation

enum DebugConstants {
    
    static let worldTrigger = Manga(id: "7ae7067a-7e68-4bd2-a064-5e3e3c059078", title: "World Trigger", authors: ["Ashihara Daisuke"], description: "A gate to another dimension has burst open, and from it emerge gigantic invincible creatures that threaten all of humanity. Earth's only defense is a mysterious group of warriors who have co-opted the alien technology in order to fight back!", genres: ["Sci-Fi", "Action", "Comedy", "Adventure", "Drama", "Mystery", "Tragedy"], coverUrl: "https://mangadex.org/covers/7ae7067a-7e68-4bd2-a064-5e3e3c059078/6742f549-20ec-48fa-ba7a-e9c54cac5ebb.jpg.512.jpg")
    
    static let userId = "xJfGEKFVB4e379fNXgQ0luNqEmI2"
    
    static let prevChapter = Chapter(id: "8b5af4d6-1c14-4848-b9d5-122b42bba786", number: "1", title: "Mikumo Osamu (Part 1)", updatedAt: chapterDate())
    static let currentChapter = Chapter(id: "227a7d66-fcd6-4711-8818-68f67b7c7502", number: "2", title: "Kuga Yuuma (Part 1)", updatedAt: chapterDate())
    static let nextChapter = Chapter(id: "39c8e983-d5ce-499c-bb8a-a4a429dbbe48", number: "3", title: "Kuga Yuuma (Part 2)", updatedAt: chapterDate())
    
    private static func chapterDate() -> Date {
        do {
            return try Date("2018-03-26T16:53:53+00:00", strategy: .iso8601)
        }
        catch {
            return Date.now
        }
    }
}
