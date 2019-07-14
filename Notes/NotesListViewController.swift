//
//  TableViewController.swift
//  Notes
//
//  Created by Denis Zayakin on 5/15/19.
//  Copyright © 2019 Denis Zayakin. All rights reserved.
//

import UIKit

enum Sort {
    case byName
    case fromNewToOld
    case fromOldToNew
}

class NotesListViewController: UITableViewController, UISearchBarDelegate, NotesDetailViewControllerDelegate {


    var noteList: [Note] = []
    var condition: NoteDetailCondition = .detail
    var selectedNote: Note?
    var sort: Sort = .fromNewToOld {
        didSet {
            DataSource.shared.sort(sort)
        }
    }
    var isSearching: Bool = false {
        didSet {
            if !isSearching {
                filteredNoteList = nil
            }
        }
    }
    var filteredNoteList: [Note]?

    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 75
        searchBar.delegate = self
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:  #selector(refreshArray), for: .valueChanged)
        self.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        reloadView()

        condition = .detail
        
        switch sort {
        case .byName:
            sortByName()
            
        case .fromNewToOld:
            sortFromNewToOld()
            
        case .fromOldToNew:
            sortFromOldToNew()
        }
 
    }

    func reloadView() {
        DataSource.shared.getNotesList() { [weak self] (noteList, error) in
            if let error = error {
                print(error)

            } else {
                self?.noteList = noteList!
                self?.tableView.reloadData()
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredNoteList?.count ?? noteList.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let note: Note = getNote(for: indexPath.row)
        toNotesDetailVC(with: .detail, note: note)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NoteTableViewCell
        
        let note: Note = getNote(for: indexPath.row)
        
        cell.dateLabel?.text = dayString(note.date)
        cell.timeLabel?.text = timeString(note.date)
        cell.detailLabel?.text = note.shortDetail
        
        return cell
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: "Изменить") { [weak self] (action, indexPath) -> Void in
            let note: Note? = self?.getNote(for: indexPath.row)
            self?.toNotesDetailVC(with: .edit, note: note)
        }
        editAction.backgroundColor = UIColor.orange
        let deleteAction = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: "Удалить") { [weak self] (action, indexPath) -> Void in
            if let note = self?.getNote(for: indexPath.row) {
                DataSource.shared.remove(note) { [weak self] (error: Error?) in
                    if let error = error {
                        print("ERROR: \(error.localizedDescription)")
                    } else {
                        self?.noteList.remove(at: indexPath.row)
                        self?.updateFilteredList(with: self?.searchBar.text)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                }
            }
        }
        return [deleteAction, editAction]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nextVC = segue.destination as? NotesDetailViewController else { return }
        nextVC.condition = condition
        nextVC.delegate = self
        if let note = selectedNote {
            nextVC.note = note
        }
    }
    
    @IBAction func addNote(_ sender: Any) {
        toNotesDetailVC(with: .add, note: nil)
    }
    
    @objc func refreshArray() {
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    func toNotesDetailVC(with conditionValue: NoteDetailCondition, note: Note?) {
        condition = conditionValue
        selectedNote = note
        self.performSegue(withIdentifier: "ShowNotesDetailViewController", sender: nil)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        isSearching = true
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
        isSearching = false
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateFilteredList(with: searchText)
        tableView.reloadData()
    }
    
    @IBAction func SortNotes(_ sender: Any) {
        let sortAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        let sortByNameAction = UIAlertAction(title: "По имени", style: .default, handler: { action in self.sortByName() })
        let sortFromNewToOldAction = UIAlertAction(title: "От новых к старым", style: .default, handler: { action in self.sortFromNewToOld() })
        let sortFromOldToNewAction = UIAlertAction(title: "От старых к новым", style: .default, handler: { action in self.sortFromOldToNew() })
        sortAlert.addAction(cancelAction)
        sortAlert.addAction(sortByNameAction)
        sortAlert.addAction(sortFromNewToOldAction)
        sortAlert.addAction(sortFromOldToNewAction)
        self.present(sortAlert, animated: true, completion: nil)
    }
    
    func sortByName() {
        sort = .byName
        reloadView()
    }
    
    func sortFromNewToOld() {
        sort = .fromNewToOld
        reloadView()
    }
    
    func sortFromOldToNew() {
        sort = .fromOldToNew
        reloadView()
    }
    
    func getNote(for index: Int) -> Note {
        if let filteredNote = filteredNoteList?[index] {
            return filteredNote
        } else {
            return noteList[index]
        }
    }
    
    private lazy var dateFormatter = DateFormatter()
    private func dayString(_ date: Date) -> String {
        dateFormatter.dateFormat = "dd.MM"
        return dateFormatter.string(from: date)
    }
    private func timeString(_ date: Date) -> String {
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: date)
    }
    
    func updateFilteredList(with text: String?) {
        if let text = text, !text.isEmpty {
            DataSource.shared.getFilteredList(by: text) { [weak self] (filteredNoteList, error) in
                if let error = error {
                    print(error)
                } else {
                    self?.filteredNoteList = filteredNoteList
                }
            }
        } else {
            filteredNoteList = nil
        }
    }
    
    func needReloadData() {
        if isSearching {
            updateFilteredList(with: searchBar.text)
        }
        tableView.reloadData()
    }
}
