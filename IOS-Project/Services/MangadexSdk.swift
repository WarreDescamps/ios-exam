//
//  Mangadex.swift
//  IOS-Project
//
//  Created by Warre Descamps on 05/12/2022.
//

import SwiftUI

class MangadexSdk: ObservableObject {
    @Published var manga = [Manga]()
    
    init() {
        getManga(query: nil)
    }
    
    private func convertToManga(_ results: Api.Types.Response.MangaSearch) {
        var mangaArr = [Manga]()
        
        for result in results.data {
            let manga = Manga(id: result.id,
                              title: result.attributes.title.en,
                              description: result.attributes.description.en,
                              coverUrl: createCoverUrl(result.id))
            mangaArr.append(manga)
        }
        
        self.manga = mangaArr
    }
    
    private func createCoverUrl(_ mangaId: String) -> String {
        var url: String = ""
        
        Api.Sdk.shared
            .get(.cover(id: mangaId)) { (result: Result<Api.Types.Response.CoverLookup, Api.Types.Error>) in
                switch result {
                case .success(let success):
                    url = "https://uploads.mangadex.org/covers/\(mangaId)/\(success.data.first(where: { cover in cover.attributes.locale == "en" })?.attributes.fileName ?? "")"
                case .failure(let failure):
                    print(failure.localizedDescription)
                }
            }
        
        return url
    }
    
    func getManga(query: String?) {
        Api.Sdk.shared
            .get(.manga(query: query)) { (result: Result<Api.Types.Response.MangaSearch, Api.Types.Error>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let success):
                        self.convertToManga(success)
                    case .failure(let failure):
                        print(failure.localizedDescription)
                    }
                }
            }
    }
}
