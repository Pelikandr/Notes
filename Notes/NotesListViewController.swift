//
//  TableViewController.swift
//  Notes
//
//  Created by Denis Zayakin on 5/15/19.
//  Copyright © 2019 Denis Zayakin. All rights reserved.
//

import UIKit

class NotesListViewController: UITableViewController, UISearchBarDelegate {
 
    var selectedNoteDetail: String = ""
    var condition: NoteDetailCondition?
    var editIndex: Int?
    
    var n1 = Note()
    var n2 = Note()
    var n3 = Note()
    var filteredNoteList = DataSource.shared.filteredNoteList
    var isSearching = DataSource.shared.isSearching
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 75
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
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if DataSource.shared.isSearching{
            return DataSource.shared.filteredNoteList.count ?? 0
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
            DataSource.shared.remove(at: indexPath.row)
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
        DataSource.shared.filteredNoteList.removeAll()
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        DataSource.shared.filteredNoteList = DataSource.shared.noteList.filter({( note : Note) -> Bool in
            return note.detail.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
        }
}
