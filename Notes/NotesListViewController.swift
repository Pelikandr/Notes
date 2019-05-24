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

class NotesListViewController: UITableViewController, UISearchBarDelegate {
 
    var condition: NoteDetailCondition = .detail
    var sort: Sort = .fromNewToOld {
        didSet {
            DataSource.shared.sort(sort)
        }
    }
    
    var filteredNoteList = DataSource.shared.filteredNoteList
    var isSearching = DataSource.shared.isSearching

    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 75
        DataSource.shared.toReloadTableview = false
        searchBar.delegate = self
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:  #selector(refreshArray), for: .valueChanged)
        self.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if DataSource.shared.toReloadTableview!{
            self.tableView.reloadData()
        }
        
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if DataSource.shared.isSearching{
            return DataSource.shared.filteredNoteList.count
        } else {
            return DataSource.shared.noteList.count
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        toNotesDetailVC(with: .detail)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NoteTableViewCell
        
        let note: Note
        if DataSource.shared.isSearching{
            note = DataSource.shared.filteredNoteList[indexPath.row]
        } else {
            note = DataSource.shared.noteList[indexPath.row]
        }
        
        cell.dateLabel?.text = dayString(note.date)
        cell.timeLabel?.text = timeString(note.date)
        cell.detailLabel?.text = note.shortDetail
        
        return cell
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: "Изменить") { [weak self] (action, indexPath) -> Void in
            self?.toNotesDetailVC(with: .edit)
        }
        editAction.backgroundColor = UIColor.orange
        let deleteAction = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: "Удалить") { (action, indexPath) -> Void in
            if DataSource.shared.isSearching == true{
                let deleteId = DataSource.shared.filteredNoteList[indexPath.row].id
                DataSource.shared.removeInfilteredNoteList(at: indexPath.row)
                for i in 0...DataSource.shared.noteList.count-1{
                    if deleteId == DataSource.shared.noteList[i].id {
                        DataSource.shared.removeInNoteList(at: i)
                        break
                    }
                }
            } else {
                DataSource.shared.removeInNoteList(at: indexPath.row)
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        return [deleteAction, editAction]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let note: Note?
        if let indexPath = tableView.indexPathForSelectedRow {
            if DataSource.shared.isSearching {
                note = DataSource.shared.filteredNoteList[indexPath.row]
            } else {
                note = DataSource.shared.noteList[indexPath.row]
            }
        } else {
            note = nil
        }
        
        if let nextVC = segue.destination as? NotesDetailViewController {
            nextVC.condition = condition
            nextVC.note = note
        }
    }
    
    @IBAction func addNote(_ sender: Any) {
        toNotesDetailVC(with: .add)
    }
    
    @objc func refreshArray() {
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    func toNotesDetailVC(with conditionValue: NoteDetailCondition) {
        condition = conditionValue
        self.performSegue(withIdentifier: "ShowNotesDetailViewController", sender: nil)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        DataSource.shared.isSearching = true
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
        DataSource.shared.isSearching = false
        DataSource.shared.cleanFilteredList()
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        DataSource.shared.filterNoteList(searchText: searchText)
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
        tableView.reloadData()
    }
    
    func sortFromNewToOld() {
        sort = .fromNewToOld
        tableView.reloadData()
    }
    
    func sortFromOldToNew() {
        sort = .fromOldToNew
        tableView.reloadData()
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
}
