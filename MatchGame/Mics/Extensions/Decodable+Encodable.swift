//
//  Decodable+Encodable.swift
//  MatchGame
//
//  Created by Mykhailo Dovhyi on 15.11.2024.
//

import Foundation

extension Decodable {
    static func configure(_ from:Data?) -> Self? {
        guard let from else {
            return nil
        }
        do {
            let decoder = PropertyListDecoder()
            let decodedData = try decoder.decode(Self.self, from: from)
            return decodedData
        } catch {
#if DEBUG
            print("error decoding db data ", error)
#endif
            return nil
        }
    }
}

extension Encodable {
    var decode: Data? {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        do {
            return try encoder.encode(self)
        }
        catch {
#if DEBUG
            print("error encoding db ", error)
#endif
            return nil
        }
    }
    
    var encode: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    var dictionary:[String:Any]? {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(self),
           let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            return json
        }
        return nil
    }
}

