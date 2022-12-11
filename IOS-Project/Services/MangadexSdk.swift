//
//  Mangadex.swift
//  IOS-Project
//
//  Created by Warre Descamps on 05/12/2022.
//

import SwiftUI

class MangadexSdk: ObservableObject {
    @Published var manga = [Manga]()
    @State private var page = 0
    @State private var total = 0
    @State private var lastQuery: String? = nil
    
    private func appendWithAuthor(manga: Manga) {
        var manga = manga
        Api.Sdk.shared
            .get(.authors(ids: manga.authors)) { (result: Result<Api.Types.Response.MangadexAuthor, Api.Types.Error>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let success):
                        manga.authors = []
                        for author in success.data {
                            manga.authors.append(author.attributes.name)
                        }
                        self.manga.append(manga)
                    case .failure(let failure):
                        print(failure.localizedDescription)
                    }
                }
            }
    }
    
    private func appendWithCoverUrl(manga: Manga) {
        var manga = manga
        Api.Sdk.shared
            .get(.cover(id: manga.id)) { (result: Result<Api.Types.Response.MangadexCover, Api.Types.Error>) in
                switch result {
                case .success(let success):
                    var fileName: String = ""
                    fileName = success.data.first?.attributes.fileName ?? ""
                    if fileName == "" {
                        manga.coverUrl = fileName
                    } else {
                        manga.coverUrl += fileName
                    }
                    self.appendWithAuthor(manga: manga)
                case .failure(let failure):
                    print(failure.localizedDescription)
                }
            }
    }
    
    private func appendManga(_ success: Api.Types.Response.MangadexManga) {
        self.total = success.total
        for result in success.data {
            if self.manga.allSatisfy({ $0.id != result.id }) {
                let title = result.attributes.title["en"]
                    ?? result.attributes.title["ja"]
                    ?? result.attributes.title["ko"]
                    ?? result.attributes.title["ru"]
                    ?? result.attributes.title["pt"]
                    ?? ""
                let description = result.attributes.description["en"]
                    ?? result.attributes.description["ja"]
                    ?? result.attributes.description["ko"]
                    ?? result.attributes.description["ru"]
                    ?? result.attributes.description["pt"]
                    ?? ""
                var genres = [String]()
                for tag in result.attributes.tags {
                    if tag.attributes.group == Api.Types.Response.Group.genre.asString {
                        if let name = tag.attributes.name["en"] {
                            genres.append(name)
                        }
                    }
                }
                var authors = [String]()
                for relation in result.relationships {
                    if relation.type == "author" {
                        authors.append(relation.id)
                    }
                }
                self.appendWithCoverUrl(manga: Manga(id: result.id,
                                                     title: title,
                                                     authors: authors,
                                                     description: description,
                                                     genres: genres,
                                                     coverUrl: "https://mangadex.org/covers/\(result.id)/"))
            }
        }
    }
    
    private func fetchManga(query: String?) {
        Api.Sdk.shared
            .get(.mangaSearch(query: query, page: page)) { (result: Result<Api.Types.Response.MangadexManga, Api.Types.Error>) in
                switch result {
                case .success(let success):
                    self.appendManga(success)
                case .failure(let failure):
                    print(failure.localizedDescription)
                }
            }
    }
    
    private func fetchManga(mangaIds: [String]) {
        Api.Sdk.shared
            .get(.mangaById(mangaIds: mangaIds)) { (result: Result<Api.Types.Response.MangadexManga, Api.Types.Error>) in
                switch result {
                case .success(let success):
                    self.appendManga(success)
                case .failure(let failure):
                    print(failure.localizedDescription)
                }
            }
    }
    
    func getManga(query: String?) {
        self.page = 0
        self.lastQuery = query
        self.manga.removeAll()
        fetchManga(query: query)
    }
    
    func getMangaById(mangaIds: [String]) {
        manga.removeAll()
        var mangaIds = mangaIds
        while mangaIds.count > 0 {
            fetchManga(mangaIds: mangaIds)
            if mangaIds.count > 100 {
                mangaIds = Array(mangaIds[100...])
            }
            else {
                mangaIds = []
            }
        }
    }
    
    func loadNextPage() {
        self.page = self.page + 1
        fetchManga(query: lastQuery)
    }
}
