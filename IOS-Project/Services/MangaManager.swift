//
//  DataManager.swift
//  IOS-Project
//
//  Created by Warre Descamps on 02/12/2022.
//

import Foundation
import Firebase

class MangaManager {
    func getManga(userId: String, completion: @escaping (([String]) -> Void)) {
        let db = Firestore.firestore()
        
        db.collection("UserManga")
            .whereField("UserId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print(error.localizedDescription)
                }
                else {
                    if let snapshot = snapshot {
                        let mangaIds = snapshot.documents.map { d in
                            return d["MangaId"] as? String ?? ""
                        }
                        if mangaIds.isEmpty {
                            return
                        }
                        completion(mangaIds)
                    }
                }
            }
        
    }
    
    func addManga(userId: String, manga: Manga, completion: @escaping (([String]) -> Void)){
        let db = Firestore.firestore()
        
        db.collection("UserManga")
            .addDocument(data: ["MangaId": manga.id, "UserId": userId]) { error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
            }
    }
    
    func deleteManga(userId: String, mangaId: String, completion: @escaping (([String]) -> Void)) {
        let db = Firestore.firestore()
        
        // get all manga in
        db.collection("UserManga")
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
                            db.collection("UserManga").document(id).delete() { error in
                                if let error = error {
                                    print(error.localizedDescription)
                                    return
                                }
                                else {
                                    self.getManga(userId: userId, completion: completion)
                                }
                            }
                        }
                    }
                }
            }
    }
}
