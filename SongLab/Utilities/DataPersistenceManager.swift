//
//  DataPersistenceManager.swift
//
//  Created by Shawn Seals on 6/11/19.
//  Copyright © 2019 Shawn Seals. All rights reserved.
//
import Foundation

final class DataPersistenceManager {
    
    static let decoder = JSONDecoder()
    static let encoder = JSONEncoder()
    
    static func save<T: Codable>(_ object: T, to fileName: String) throws {
        do {
            let url = createDocumentURL(withFileName: fileName)
            let data = try encoder.encode(object)
            try data.write(to: url, options: .atomic)
        } catch (let error) {
            print("Save failed: Object: `\(object)`, " + "Error: `\(error)`")
            throw error
        }
    }
    
    static func retrieve<T: Codable>(_ type: T.Type, from fileName: String) throws -> T {
        let url = createDocumentURL(withFileName: fileName)
        return try retrieve(T.self, from: url)
    }
    
    static func retrieve<T: Codable>(_ type: T.Type, from url: URL) throws -> T {
        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode(T.self, from: data)
        } catch (let error) {
            print("Retrieve failed: URL: `\(url)`, Error: `\(error)`")
            throw error
        }
    }
    
    static func createDocumentURL(withFileName fileName: String) -> URL {
        let fileManager = FileManager.default
        let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return url.appendingPathComponent(fileName).appendingPathExtension("json")
    }
    
    static func delete(_ filename: String) throws {
        let fileManager = FileManager.default
        let url = createDocumentURL(withFileName: filename)
        return try fileManager.removeItem(at: url)
    }
    
    static func saveData(name: String, data: Data) -> Bool {
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return false
        }
        do {
            guard let directoryWithPathComponent = directory.appendingPathComponent(name) else { return false }
            try data.write(to: directoryWithPathComponent)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
}
