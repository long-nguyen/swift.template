//
//  DBHelper.swift
//  Template
//
//  Created by Nguyen Tien LONG on 5/28/19.
//  Copyright © 2019 Active User Co.,LTD. All rights reserved.
//

import Foundation

//TODO: Check it
class DbMng {
    
    static let instance = DbMng()
    let dbName = "myDb.sqlite3"
    let dbVersion:UInt32 = 1
    var _dbPath: String

    private init() {
        let documentFolderPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        _dbPath = documentFolderPath.appendingFormat("/\(dbName)")
        let avail = FileManager.default.fileExists(atPath: _dbPath)
        if avail {
            //Old DB
//            updateDB()
        } else {
            //No DB, create it
            if generateTable() {
            }
        }
    }
    
    func generateTable() ->Bool {
        let database = FMDatabase(path: _dbPath)
        guard database.open() else {
            return false
        }
        do {
            try database.executeUpdate("create table test(name text, imageUrl text)", values: nil)
            database.userVersion = UInt32(dbVersion)
            return true
        } catch {
            print("failed: \(error.localizedDescription)")
        }
        defer {
            database.close()
        }
        
        return false
    }
    
    func updateDB()->Bool {
        //Migration check
        return false
    }

    func insertSampleItems(items:[SampleModel]) -> Bool {
        let database = FMDatabase(path: _dbPath)
        guard database.open() else {
            return false
        }
        do {
            database.beginTransaction()
            for data in items {
                try database.executeUpdate("insert into test (name, imageUrl) values (?, ?)", values: [data.name ?? "", data.imageUrl ?? ""])
            }
            database.commit()
            return true
        } catch {
            print("failed: \(error.localizedDescription)")
        }
        defer {
            database.close()
        }
        return false
    }

    func getAllItems() -> [SampleModel] {
        var items = [SampleModel]()
        let database = FMDatabase(path: _dbPath)
        guard database.open() else {
            return items
        }
        do {
            let rs = try database.executeQuery("select * from test", values: nil)
            while rs.next() {
                var mdel = SampleModel()
                mdel.name = rs.string(forColumn: "name")
                mdel.imageUrl = rs.string(forColumn: "imageUrl")
                items.append(mdel)
            }
            rs.close()
        } catch {
            print("failed: \(error.localizedDescription)")
        }
        defer {
            database.close()
        }
        return items
    }
}
