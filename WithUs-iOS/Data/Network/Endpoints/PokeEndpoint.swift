//
//  PokeEndpoint.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/3/26.
//

import Foundation
import Alamofire

enum PokeEndpoint: EndpointProtocol {
    case pokePartner(Int)
    
    var path: String {
        switch self {
        case .pokePartner(let id):
            return "/api/users/\(id)/poke"
        }
    }
    
    var method: HTTPMethod {
        .post
    }
}
