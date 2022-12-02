//
//  DataManager.swift
//  IOS-Project
//
//  Created by Warre Descamps on 02/12/2022.
//

import Foundation
import Firebase

class DataManager: ObservableObject {
    func getManga(userId: String) -> [Manga] {
        var mangaArr: [Manga] = []
        let db = Firestore.firestore()
        let ref = db.collection("Manga")
        ref.getDocuments{snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()

                    let id = document.documentID
                    let title = data["Title"] as? String ?? ""
                    let description = data["Description"] as? String ?? ""
                    let coverUrl = data["CoverUrl"] as? String ?? ""
                    mangaArr.append(Manga(id: id, title: title, description: description, coverUrl: coverUrl))
                }
            }
        }
        return mangaArr
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
