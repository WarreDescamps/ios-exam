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
            
            struct MangaSearch: Decodable {
                var result: String
                var data:  [Data]
                
                struct Data: Decodable{
                    var id: String
                    var attributes: Attributes
                    
                    struct Attributes: Decodable {
                        var title: MultiLanguage
                        var description: MultiLanguage
                        
                        struct MultiLanguage: Decodable {
                            var en: String
                        }
                    }
                }
            }
            
            struct CoverLookup: Decodable {
                var result: String
                var data: [Data]
                
                struct Data: Decodable {
                    var attributes: Attributes
                    
                    struct Attributes: Decodable {
                        var fileName: String
                        var locale: String
                    }
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
            case manga(query: String?)
            case cover(id: String)
            
            var url: URL {
                var components = URLComponents()
                components.host = "api.mangadex.org"
                components.scheme = "https"
                
                switch self {
                case .manga(let query):
                    components.path = "/manga"
                    if query != nil {
                        components.queryItems = [URLQueryItem(name: "title", value: query)]
                    }
                case .cover(let id):
                    components.path = "/cover"
                    components.queryItems = [
                        URLQueryItem(name: "manga[]", value: id),
                        URLQueryItem(name: "order[createdAt]", value: "desc"),
                    ]
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
