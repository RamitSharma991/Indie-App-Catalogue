//
//  PhraseModel.swift
//  WordSubs
//
//  Created by Ramit Sharma on 20/11/24.
//

import Foundation

struct Phrase: Identifiable, Codable {
    let id: UUID
    let word: String
    let phrase: String
    let usage: String
    
    enum CodingKeys: String, CodingKey {
        case id, word, phrase, usage
    }
    
    init(id: UUID = UUID(), word: String, phrase: String, usage: String) {
        self.id = id
        self.word = word
        self.phrase = phrase
        self.usage = usage
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        word = try container.decode(String.self, forKey: .word)
        phrase = try container.decode(String.self, forKey: .phrase)
        usage = try container.decode(String.self, forKey: .usage)
        
        // Handle string ID from JSON and convert to UUID
        if let idString = try? container.decode(String.self, forKey: .id) {
            id = UUID(uuidString: idString) ?? UUID()
        } else {
            id = UUID()
        }
    }
}
