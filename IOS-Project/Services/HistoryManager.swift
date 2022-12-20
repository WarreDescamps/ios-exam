//
//  HistoryManager.swift
//  IOS-Project
//
//  Created by Warre Descamps on 20/12/2022.
//

import Foundation
import Firebase

class HistoryManager: ObservableObject {
    static let shared = HistoryManager()
    @Published var history: History? = nil
    @Published var fullHistory = [History]()
    
    func getHistory(userId: String? = nil, manga: Manga) {
        let userId = userId ?? SingletonManager.userInstance() ?? ""
        let db = Firestore.firestore()

        db.collection("UserHistory")
            .whereField("UserId", isEqualTo: userId)
            .whereField("MangaId", isEqualTo: manga.id)
            .getDocuments { snapshot, error in
                if let error = error {
                    print(error.localizedDescription)
                }
                else {
                    if let snapshot = snapshot {
                        let histories = snapshot.documents.map { d in
                            let timestamp = d["LastRead"] as? Timestamp
                            var date: Date? = nil
                            if let timestamp = timestamp {
                                date = timestamp.dateValue()
                            }
                            return History(
                                mangaId: d["MangaId"] as? String ?? "",
                                lastRead: date,
                                chapters: d["Chapters"] as? [String] ?? [String]()
                                )
                        }
                        if histories.count == 1 {
                            if let history = histories.first {
                                self.history = history
                            }
                        }
                        else if histories.count == 0 {
                            print("get history returned 0")
                        }
                        else if histories.count > 1 {
                            print("get history returned more than 1")
                        }
                    }
                }
            }
    }
    
    func fetchFullHistory(userId: String? = nil) {
        let userId = userId ?? SingletonManager.userInstance() ?? ""
        let db = Firestore.firestore()

        db.collection("UserHistory")
            .whereField("UserId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print(error.localizedDescription)
                }
                else {
                    if let snapshot = snapshot {
                        self.fullHistory = snapshot.documents.map { d in
                            let timestamp = d["LastRead"] as? Timestamp
                            var date: Date? = nil
                            if let timestamp = timestamp {
                                date = timestamp.dateValue()
                            }
                            return History(
                                mangaId: d["MangaId"] as? String ?? "",
                                lastRead: date,
                                chapters: d["Chapters"] as? [String] ?? [String]()
                                )
                        }
                    }
                }
            }
    }
    
    func updateHistory(userId: String? = nil, manga: Manga) {
        let userId = userId ?? SingletonManager.userInstance() ?? ""
        let db = Firestore.firestore()
        
        db.collection("UserHistory")
            .whereField("UserId", isEqualTo: userId)
            .whereField("MangaId", isEqualTo: manga.id)
            .getDocuments { snapshot, error in
                if let error = error {
                    print(error.localizedDescription)
                }
                else {
                    if let snapshot = snapshot {
                        let documentIds = snapshot.documents.map() { d in
                            return d.documentID
                        }
                        if documentIds.count == 1 {
                            if let id = documentIds.first {
                                db.collection("UserHistory").document(id)
                                    .setData(["LastRead": self.history?.lastRead ?? NSNull(), "Chapters": self.history?.chapters ?? [String]()])
                                if let error = error {
                                    print(error.localizedDescription)
                                    return
                                }
                            }
                        }
                        else if documentIds.count == 0 {
                            print("update history returned 0")
                        }
                        else if documentIds.count > 1 {
                            print("update history returned more than 1")
                        }
                    }
                }
            }
    }
    
    func addHistory(userId: String? = nil, manga: Manga) {
        let userId = userId ?? SingletonManager.userInstance() ?? ""
        let db = Firestore.firestore()
        
        db.collection("UserHistory")
            .addDocument(data: ["MangaId": manga.id, "UserId": userId, "LastRead": NSNull(), "Chapters": [String]()]) { error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
            }
        self.history = History(mangaId: manga.id, lastRead: nil, chapters: [String]())
    }
    
    func deleteHistory(userId: String? = nil, mangaId: String) {
        let userId = userId ?? SingletonManager.userInstance() ?? ""
        let db = Firestore.firestore()
        
        // get all manga in
        db.collection("UserHistory")
            .whereField("UserId", isEqualTo: userId)
            .whereField("MangaId", isEqualTo: mangaId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print(error.localizedDescription)
                }
                else {
                    if let snapshot = snapshot {
                        let documentIds = snapshot.documents.map() { d in
                            return d.documentID
                        }
                        for id in documentIds {
                            db.collection("UserHistory").document(id).delete() { error in
                                if let error = error {
                                    print(error.localizedDescription)
                                    return
                                }
                            }
                        }
                    }
                }
            }
        self.history = nil
    }
}
