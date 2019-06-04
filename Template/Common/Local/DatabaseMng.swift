//
//  DatabaseMng.swift
//  Template
//
//  Created by Company on 2019/05/29.
//  Copyright © 2019 Active User Co.,LTD. All rights reserved.
//

import GRDB
import Foundation

class DatabaseMng {
    static let instance = DatabaseMng()
    var dbQueue: DatabaseQueue!
    let dbName = "myDb.sqlite3"

    private init() {
        do {
            let databaseURL = try FileManager.default
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent(dbName)
            dbQueue = try DatabaseQueue(path: databaseURL.path)
            try migrator.migrate(dbQueue)
        } catch let exception {
            LOG("Database can not be used: \(exception.localizedDescription)")
        }
    }
    
    func clearAll() -> Bool? {
        do {
            try dbQueue.write { db in
                try db.execute(sql: "truncate table test")
            }
            return true
        } catch let exception {
            LOG(exception)
            return false
        }
    }
    
    func insertItems(items:[SampleModel]) -> Bool? {
        do {
            try dbQueue.inTransaction { db in
                for data in items {
                    try db.execute(sql: "insert into test (name, imageUrl) values (?, ?)", arguments: [data.name ?? "", data.imageUrl ?? ""])
                }
                return .commit
            }
            return true
        } catch let exception {
            LOG(exception)
            return false
        }
    }
    
    func getAllItems() -> [SampleModel] {
        var items = [SampleModel]()
        do {
            try dbQueue.read { db in
                let rows = try Row.fetchCursor(db, sql: "SELECT * from test")
                while let row = try rows.next() {
                    let item = SampleModel()
                    item.id = row["id"]
                    item.name = row["name"]
                    item.imageUrl = row["imageUrl"]
                    items.append(item)
                }
            }
        } catch let exception {
            LOG(exception)
        }
        return items
    }

    //-------------------------------------- Migration
    var migrator: DatabaseMigrator {
        var mg = DatabaseMigrator()
        mg.registerMigration("v1") { db in
            try db.create(table: "test") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text).notNull().collate(.localizedCaseInsensitiveCompare)
                t.column("imageUrl", .text).notNull()
            }
        }
        return mg
    }
}
