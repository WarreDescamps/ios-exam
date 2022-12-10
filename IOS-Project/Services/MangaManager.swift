//
//  DataManager.swift
//  IOS-Project
//
//  Created by Warre Descamps on 02/12/2022.
//

import Foundation
import Firebase

class MangaManager {
    var userId: String = ""
    static let shared = MangaManager()
    
    func login(userId: String) {
        MangaManager.shared.userId = userId
    }
    
    func getManga(userId: String? = nil, completion: @escaping (([String]) -> Void)) {
        let userId = userId ?? self.userId
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
    
    func addManga(userId: String? = nil, manga: Manga){
        let userId = userId ?? self.userId
        let db = Firestore.firestore()
        
        db.collection("UserManga")
            .addDocument(data: ["MangaId": manga.id, "UserId": userId]) { error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
            }
    }
    
    func deleteManga(userId: String? = nil, mangaId: String) {
        let userId = userId ?? self.userId
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
                            }
                        }
                    }
                }
            }
    }
}
