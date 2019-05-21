//
//  Data.swift
//  Notes
//
//  Created by Denis Zayakin on 5/15/19.
//  Copyright © 2019 Denis Zayakin. All rights reserved.
//

import Foundation

struct Note {
    var date: String
    var time: String
    var detail: String
    
    init?() {
        let dateFormatter = DateFormatter()
        let timeFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM"
        timeFormatter.dateFormat = "HH:mm"
        date = dateFormatter.string(from: Date())
        time = timeFormatter.string(from: Date())
        detail = ""
    }
}

class DataSource {
    
    static var shared = DataSource()
    
    private(set) var noteList: [Note] = []
    
    var selectedNoteDetail: String?
    var noteIndex: Int?
    var toReloadTableview: Bool?

    func append(note: Note) {
        self.noteList.append(note)
    }
    func remove(at index: Int) {
        self.noteList.remove(at: index)
    }
    func edit(at index: Int, editedNote: Note) {
        self.noteList[index] = editedNote
    }
}
