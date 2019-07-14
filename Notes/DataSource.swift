//
//  Data.swift
//  Notes
//
//  Created by Denis Zayakin on 5/15/19.
//  Copyright © 2019 Denis Zayakin. All rights reserved.
//

import Foundation
import CoreData

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

    private var sortingType: Sort = .byName
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Notes")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func getNotesList(completion: @escaping (([Note]?, Error?) -> Void)) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let `self` = self else { return }

            do {
                let notes =  try self.persistentContainer.viewContext
                    .fetch(NSFetchRequest<BaseNote>(entityName: "BaseNote"))
                    .compactMap({ (base: BaseNote) -> Note? in
                        guard let id = base.id, let date = base.date, let detail = base.detail else {
                            return nil
                        }
                        return Note(id: id, date: date, detail: detail)
                    })
                    .sorted(by: { (note0: Note, note1: Note) -> Bool in
                        switch self.sortingType {
                        case .byName:
                            return note0.detail < note1.detail
                        case .fromNewToOld:
                            return note0.date > note1.date
                        case .fromOldToNew:
                            return note0.date < note1.date
                        }
                    })

                DispatchQueue.main.async {
                    completion(notes, nil)
                }

            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }

    func append(note: Note, completion: ((Error?) -> Void)?) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let `self` = self else { return }

            let managedContext = self.persistentContainer.newBackgroundContext()

            let baseNote = BaseNote(context: managedContext)
            baseNote.id = note.id
            baseNote.date = note.date
            baseNote.detail = note.detail

            do {
                try managedContext.save()
                DispatchQueue.main.async {
                    completion?(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion?(error)
                }
            }
        }
    }
    func update(_ note: Note, completion: ((Error?) -> Void)?) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let `self` = self else { return }

            let managedContext = self.persistentContainer.newBackgroundContext()

            let request = NSFetchRequest<BaseNote>(entityName: "BaseNote")
            request.predicate = NSPredicate(format: "id == [c] %@", note.id)
            do {
                if let baseNote = try managedContext.fetch(request).first {
                    baseNote.id = note.id
                    baseNote.date = note.date
                    baseNote.detail = note.detail
                    try managedContext.save()
                    DispatchQueue.main.async {
                        completion?(nil)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion?(error)
                }
            }
        }
    }
    func getFilteredList(by text: String, completion: @escaping (([Note]?, Error?) -> Void)) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let `self` = self else { return }
            do {
                let request = NSFetchRequest<BaseNote>(entityName: "BaseNote")
                request.predicate = NSPredicate(format: "detail contains[c] %@", text)

                let notes =  try self.persistentContainer.viewContext
                    .fetch(request)
                    .compactMap({ (base: BaseNote) -> Note? in
                        guard let id = base.id, let date = base.date, let detail = base.detail else {
                            return nil
                        }
                        return Note(id: id, date: date, detail: detail)
                    })
                DispatchQueue.main.async {
                    completion(notes, nil)
                }

            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }
    
    func remove(_ note: Note, completion: ((Error?) -> Void)?) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let `self` = self else { return }

            let managedContext = self.persistentContainer.newBackgroundContext()

            let request = NSFetchRequest<BaseNote>(entityName: "BaseNote")
            request.predicate = NSPredicate(format: "id == [c] %@", note.id)
            do {
                if let object = try managedContext.fetch(request).first {
                    managedContext.delete(object)
                    try managedContext.save()
                    DispatchQueue.main.async {
                        completion?(nil)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion?(error)
                }
            }
        }
    }

    func sort(_ type: Sort) {
        sortingType = type
    }
}
