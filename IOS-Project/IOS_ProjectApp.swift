//
//  IOS_ProjectApp.swift
//  IOS-Project
//
//  Created by Docent on 17/11/2022.
//

import SwiftUI
import Firebase

@main
struct IOS_ProjectApp: App {
    @StateObject var mangaManager = MangaManager()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(mangaManager)
        }
    }
}
