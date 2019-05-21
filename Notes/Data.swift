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
    var id: Int
    
    init?() {
        let dateFormatter = DateFormatter()
        let timeFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM"
        timeFormatter.dateFormat = "HH:mm"
        date = dateFormatter.string(from: Date())
        time = timeFormatter.string(from: Date())
        detail = ""
        id = DataSource.shared.globalId
    }
}

class DataSource {
    
    static var shared = DataSource()
    
    private(set) var noteList: [Note] = []
    
    var filteredNoteList: [Note] = []
    var isSearching: Bool = false
    var globalId: Int = 0
    
    var selectedNoteDetail: String?
    var noteIndex: Int?
    var toReloadTableview: Bool?

    func append(note: Note) {
        globalId += 1
        print("GLOBALID = \(globalId)")
        self.noteList.append(note)
    }
    func remove(at index: Int) {
        if isSearching == true{
            let deleteId = filteredNoteList[index].id
            self.filteredNoteList.remove(at: index)
            for i in 0...noteList.count-1{
                if deleteId == noteList[i].id {
                    self.noteList.remove(at: i)
                }
            }
        } else {
            self.noteList.remove(at: index)
        }
        
    }
    func edit(at index: Int, editedNote: Note) {
        if isSearching{
            let editId = filteredNoteList[index].id
            self.filteredNoteList[index] = editedNote
            for i in 0...noteList.count-1{
                if editId == noteList[i].id {
                    self.noteList[i] = editedNote
                }
            }
        } else {
            self.noteList[index] = editedNote
        }
    }
}
