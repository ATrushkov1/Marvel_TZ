//
//  HeroMarvelModel.swift
//  FirstTZ
//
//  Created by Алексей Трушков on 28.12.2022.
//

import Foundation

struct HeroMarvelModel: Codable {
    let id: Int
    let name: String
    let description: String
    let modified: String
    let thumbnail: Thumbnail
    
    struct Thumbnail: Codable {
        let path: String
        let `extension`: String
        var url: URL? {
            return URL(string: path + "." + `extension`)
        }
    }
}

extension HeroMarvelModel: Hashable {
    static func == (lhs: HeroMarvelModel, rhs: HeroMarvelModel) -> Bool {
        return lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
