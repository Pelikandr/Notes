//
//  Data.swift
//  Notes
//
//  Created by Denis Zayakin on 5/15/19.
//  Copyright © 2019 Denis Zayakin. All rights reserved.
//

import Foundation

struct Note {
    let id: String
    let date: Date
    let detail: String
    
    var shortDetail: String {
        if detail.count > 100 {
            let index = detail.index(detail.startIndex, offsetBy: 100)
            return String(detail[..<index]) + "..."
        } else {
            return detail
        }
    }
}

class DataSource {
    
    static var shared = DataSource()
    
    private(set) var noteList: [Note] = []

    func append(note: Note) {
        self.noteList.append(note)
    }
    func update(_ note: Note) {
        if let index = noteList.firstIndex(where: { $0.id == note.id }) {
            noteList[index] = note
        }
    }
    func getFilteredList(by text: String) -> [Note] {
        return noteList.filter({ $0.detail.lowercased().contains(text.lowercased()) })
    }
    
    func remove(_ note: Note) {
        if let index = noteList.firstIndex(where: { $0.id == note.id }) {
            noteList.remove(at: index)
        }
    }
        
    func sort(_ type: Sort) {
        switch type {
        case .byName:
            noteList.sort { return $0.detail < $1.detail }
        case .fromNewToOld:
            noteList.sort { return $0.date > $1.date }
        case .fromOldToNew:
            noteList.sort { return $0.date < $1.date }
        }
    }
 
}
