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
 
    var selectedNoteDetail: String = ""
    var condition: NoteDetailCondition?
    var sort: Sort?
    var editIndex: Int?
    
    var filteredNoteList = DataSource.shared.filteredNoteList
    var isSearching = DataSource.shared.isSearching

    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 75
        DataSource.shared.toReloadTableview = false
        searchBar.delegate = self
        sort = .fromNewToOld
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:  #selector(refreshArray), for: .valueChanged)
        self.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if DataSource.shared.toReloadTableview!{
            self.tableView.reloadData()
        }
        
        switch sort {
        case .byName?: do {
            sortByName()
            }
        case .fromNewToOld?: do {
            sortFromNewToOld()
            }
        case .fromOldToNew?: do {
            sortFromOldToNew()
            }
        case .none:
            print("Sort is none")
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
        if DataSource.shared.isSearching{
            self.selectedNoteDetail = DataSource.shared.filteredNoteList[indexPath.row].detail
            condition = .detail
            toNotesDetailVC()
        } else {
            self.selectedNoteDetail = DataSource.shared.noteList[indexPath.row].detail
            condition = .detail
            toNotesDetailVC()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NoteTableViewCell
        if DataSource.shared.isSearching{
            let filteredNotelistIndex = DataSource.shared.filteredNoteList[indexPath.row]
            cellOutput(cell: cell, indexPath: indexPath, noteListIndex: filteredNotelistIndex)
        } else {
            let noteListIndex = DataSource.shared.noteList[indexPath.row]
            cellOutput(cell: cell, indexPath: indexPath, noteListIndex: noteListIndex)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: "Изменить") { [weak self] (action, indexPath) -> Void in
            self?.condition = .edit
            self?.editIndex = indexPath.row
            self?.toNotesDetailVC()
        }
        editAction.backgroundColor = UIColor.orange
        let deleteAction = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: "Удалить") { [weak self] (action, indexPath) -> Void in
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
        if let indexPath = tableView.indexPathForSelectedRow {
            if DataSource.shared.isSearching == true  {
                if let nextVC = segue.destination as? NotesDetailViewController {
                    nextVC.detail = DataSource.shared.filteredNoteList[indexPath.row].detail
                    nextVC.condition = condition
                }
            } else {
                if let nextVC = segue.destination as? NotesDetailViewController {
                    nextVC.detail = self.selectedNoteDetail
                    nextVC.condition = condition
                    nextVC.editIndex = self.editIndex
                }
            }
        }
        if let nextVC = segue.destination as? NotesDetailViewController {
            nextVC.condition = condition
            nextVC.editIndex = self.editIndex
        }
    }
    
    @IBAction func addNote(_ sender: Any) {
        condition = .add
        toNotesDetailVC()
    }
    
    
    @objc func refreshArray() {
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    func cellOutput(cell: NoteTableViewCell, indexPath: IndexPath, noteListIndex: Note) {
        cell.dateLabel?.text = noteListIndex.date
        cell.timeLabel?.text = noteListIndex.time
        if noteListIndex.detail.count > 100 {
            let index = noteListIndex.detail.index(noteListIndex.detail.startIndex, offsetBy: 100)
            cell.detailLabel?.text = String(noteListIndex.detail[..<index]) + "..."
        } else {
            cell.detailLabel?.text = noteListIndex.detail
        }
    }
    
    func toNotesDetailVC() {
        self.performSegue(withIdentifier: "ShowNotesDetailViewController", sender: nil)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        DataSource.shared.isSearching = true
        self.condition = .add
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
        DataSource.shared.sortedNotes = DataSource.shared.noteList.sorted(by: {$0.detail < $1.detail})
        DataSource.shared.sort()
        tableView.reloadData()
    }
    
    func sortFromNewToOld() {
        sort = .fromNewToOld
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM yyyy HH:mm:ss"
        DataSource.shared.sortedNotes = DataSource.shared.noteList.sorted(by:
            { dateFormatter.date(from: $0.dateForSort)!.timeIntervalSinceNow  > dateFormatter.date(from: $1.dateForSort)!.timeIntervalSinceNow})
        DataSource.shared.sort()
        tableView.reloadData()
    }
    
    func sortFromOldToNew() {
        sort = .fromOldToNew
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM yyyy HH:mm:ss"
        DataSource.shared.sortedNotes = DataSource.shared.noteList.sorted(by:
            { dateFormatter.date(from: $0.dateForSort)!.timeIntervalSinceNow  < dateFormatter.date(from: $1.dateForSort)!.timeIntervalSinceNow})
        DataSource.shared.sort()
        tableView.reloadData()
    }
    
}
