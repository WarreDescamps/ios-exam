//
//  DataManager.swift
//  IOS-Project
//
//  Created by Warre Descamps on 02/12/2022.
//

import Foundation
import Firebase

class MangaManager: ObservableObject {
    @Published var manga = [Manga]()
    
    private func addNewManga(manga: Manga) {
        let db = Firestore.firestore()
        
        db.collection("Manga")
            .document(manga.id)
            .setData(["Title": manga.title, "Description": manga.description, "CoverUrl": manga.coverUrl]) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    private func getSingleManga(mangaId: String) -> Manga? {
        let db = Firestore.firestore()
        
        var mangaArr: [Manga] = []
        db.collection("Manga")
            .whereField(FieldPath.documentID(), isEqualTo: mangaId)
            .getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    mangaArr = snapshot.documents.map { d in
                        return Manga(id: d.documentID,
                                     title: d["Title"] as? String ?? "",
                                     description: d["Description"] as? String ?? "",
                                     coverUrl: d["CoverUrl"] as? String ?? "")
                    }
                }
            }
        }
        if mangaArr.isEmpty {
            return nil
        }
        return mangaArr.first
    }
    
    func getManga(userId: String) {
        manga.removeAll()
        let db = Firestore.firestore()
        
        var mangaIds: [String] = []
        db.collection("UserManga")
            .whereField("UserId", isEqualTo: userId)
            .getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    mangaIds = snapshot.documents.map { d in
                        return d["MangaId"] as? String ?? ""
                    }
                }
            }
            else {
                print(error!.localizedDescription)
                return
            }
        }
        if mangaIds.isEmpty {
            return
        }
        db.collection("Manga")
            .whereField(FieldPath.documentID(), in: mangaIds)
            .getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    DispatchQueue.main.async {
                        self.manga = snapshot.documents.map { d in
                            return Manga(id: d.documentID,
                                         title: d["Title"] as? String ?? "",
                                         description: d["Description"] as? String ?? "",
                                         coverUrl: d["CoverUrl"] as? String ?? "")
                        }
                    }
                }
            }
            else {
                print(error!.localizedDescription)
                return
            }
        }
    }
    
    func addManga(userId: String, manga: Manga){
        if self.getSingleManga(mangaId: manga.id) == nil {
            self.addNewManga(manga: manga)
        }
        let db = Firestore.firestore()
        
        db.collection("UserManga")
            .addDocument(data: ["MangaId": manga.id, "UserId": userId]) { error in
                if error == nil {
                    self.getManga(userId: userId)
                }
                else {
                    print(error!.localizedDescription)
                    return
                }
        }
    }
    
    func deleteManga(userId: String, mangaId: String) {
        let db = Firestore.firestore()
        
        var documentIds: [String] = []
        db.collection("UserManga")
            .whereField("UserId", isEqualTo: userId)
            .whereField("MangaId", isEqualTo: mangaId)
            .getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    documentIds = snapshot.documents.map() { d in
                        return d.documentID
                    }
                }
            }
        }
        for id in documentIds {
            db.collection("UserManga").document(id).delete() { error in
                if error == nil {
                    DispatchQueue.main.async {
                        self.manga.removeAll { manga in
                            return manga.id == mangaId
                        }
                    }
                }
                else {
                    print(error!.localizedDescription)
                    return
                }
            }
        }
    }
}
