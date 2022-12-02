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
    
    func getManga(userId: String) {
        manga.removeAll()
        let db = Firestore.firestore()
        
        var mangaIds: [String] = []
        db.collection("UserManga").whereField("UserId", isEqualTo: userId).getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            if let snapshot = snapshot {
                mangaIds = snapshot.documents.map { d in
                    return d["MangaId"] as? String ?? ""
                }
            }
        }
        guard !mangaIds.isEmpty else {
            return
        }
        db.collection("Manga").whereField(FieldPath.documentID(), in: mangaIds).getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
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
    }
        
    func addManga(manga: Manga){
        let db = Firestore.firestore()
        let ref = db.collection("Manga").document(manga.id)
        ref.setData(["Title": manga.title, "Description": manga.description, "CoverUrl": manga.coverUrl]) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
}
