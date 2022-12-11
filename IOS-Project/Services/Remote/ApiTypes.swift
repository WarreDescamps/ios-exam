//
//  ApiTypes.swift
//  Music
//
//  Created by Warre Descamps on 05/12/2022.
//

import UIKit

extension Api {
    
    enum Types {
        
        enum Response {
            
            struct MangadexManga: Decodable {
                var data:  [Data]
                var total: Int
                
                struct Data: Decodable{
                    var id: String
                    var attributes: Attributes
                    var relationships : [Relation]
                    
                    struct Attributes: Decodable {
                        var title: [String: String]
                        var description: [String: String]
                        var tags: [Tag]
                        
                        struct Tag: Decodable {
                            var attributes: NameAttribute
                            
                            struct NameAttribute: Decodable {
                                var name: [String: String]
                                var group: String
                            }
                        }
                    }
                    
                    struct Relation: Decodable {
                        var id: String
                        var type: String
                    }
                }
            }
            
            struct MangadexAuthor: Decodable {
                var data: [Data]
                
                struct Data: Decodable {
                    var attributes: Attributes
                    
                    struct Attributes: Decodable {
                        var name: String
                    }
                }
            }
            
            struct MangadexCover: Decodable {
                var data: [Data]
                
                struct Data: Decodable {
                    var attributes: Attributes
                    
                    struct Attributes: Decodable {
                        var fileName: String
                        var locale: String
                    }
                }
            }
            
            enum Group {
                case format
                case genre
                
                var asString: String
                {
                    var posibility = ""
                    switch self {
                    case .format:
                        posibility = "format"
                    case .genre:
                        posibility = "genre"
                    }
                    return posibility
                }
            }
            
        }
        
        enum Request {
            
            struct Empty: Encodable {}
            
        }
        
        enum Error: LocalizedError {
            case generic(reason: String)
            case `internal`(reason: String)
            
            var errorDescription: String? {
                switch self {
                case .generic(let reason):
                    return reason
                case .internal(let reason):
                    return "Internal Error: \(reason)"
                }
            }
        }
        
        enum Endpoint {
            case mangaSearch(query: String?, page: Int)
            case mangaById(mangaIds: [String])
            case cover(id: String)
            case authors(ids: [String])
            
            var url: URL {
                var components = URLComponents()
                components.host = "api.mangadex.org"
                components.scheme = "https"
                
                switch self {
                case .mangaSearch(let query, let page):
                    let pageLimit = 20
                    components.path = "/manga"
                    components.queryItems = [
                        URLQueryItem(name: "contentRating[]", value: "safe"),
                        URLQueryItem(name: "limit", value: "\(pageLimit)"),
                        URLQueryItem(name: "offset", value: "\(page * pageLimit)")
                    ]
                    if query != nil {
                        components.queryItems?.append(URLQueryItem(name: "title", value: query))
                    }
                case .mangaById(let mangaIds):
                    components.path = "/manga"
                    components.queryItems = []
                    if !mangaIds.isEmpty {
                        var toRemove = 100
                        if mangaIds.count < toRemove {
                            toRemove = mangaIds.count
                        }
                        for id in mangaIds[0..<toRemove] {
                            components.queryItems?.append(URLQueryItem(name: "ids[]", value: id))
                        }
                        components.queryItems?.append(URLQueryItem(name: "limit", value: "100"))
                    }
                    else {
                        components.queryItems?.append(URLQueryItem(name: "limit", value: "0"))
                    }
                case .cover(let id):
                    components.path = "/cover"
                    components.queryItems = [
                        URLQueryItem(name: "manga[]", value: id),
                        URLQueryItem(name: "order[volume]", value: "desc"),
                        URLQueryItem(name: "limit", value: "1")
                    ]
                case .authors(let ids):
                    components.path = "/author"
                    if !ids.isEmpty {
                        components.queryItems = []
                        for id in ids {
                            components.queryItems?.append(URLQueryItem(name: "ids[]", value: id))
                        }
                    }
                    else {
                        components.queryItems = [URLQueryItem(name: "limit", value: "0")]
                    }
                }
                return components.url!
            }
        }
        
        enum Method: String {
            case get
            case post
        }
        
    }
    
}
