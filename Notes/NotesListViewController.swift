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
    var filteredNoteList: [Note]?
    var isSearching: Bool = false
 
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 75
        DataSource.shared.toReloadTableview = false
        searchBar.delegate = self

        n1!.date = "12.03.19"
        n1!.time = "12:30"
        n1!.detail = "fjdfj s dsjf als;alsdk hh dsaldk gj sld kdsaf kjdsk flsd"
        for _ in 0...19 {
            DataSource.shared.append(note: n1!)
        }
        n2!.date = "12.03.19"
        n2!.time = "12:31"
        n2!.detail = "qqqweq weq we qwe qwe qw"
        for _ in 0...20 {
            DataSource.shared.append(note: n2!)
        }
        
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
        if isSearching{
            return filteredNoteList?.count ?? 0
        } else {
            return DataSource.shared.noteList.count
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedNoteDetail = DataSource.shared.noteList[indexPath.row].detail
        condition = .detail
        toNotesDetailVC()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NoteTableViewCell
        if isSearching{
            let filteredNotelistIndex = filteredNoteList![indexPath.row]
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
            if isSearching == true  {
                print(filteredNoteList![indexPath.row].detail)
                if let nextVC = segue.destination as? NotesDetailViewController {
                    nextVC.detail = filteredNoteList![indexPath.row].detail
                    nextVC.condition = self.condition
                    nextVC.editIndex = self.editIndex
                }
            } else {
                if let nextVC = segue.destination as? NotesDetailViewController {
                    nextVC.detail = self.selectedNoteDetail
                    nextVC.condition = self.condition
                    nextVC.editIndex = self.editIndex
                }
            }
        }
    }
    
    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            if isSearching == true  {
                print(filteredNoteList![indexPath.row].detail)
                if let nextVC = segue.destination as? NotesDetailViewController {
                    nextVC.detail = filteredNoteList![indexPath.row].detail
                    nextVC.condition = self.condition
                }
            } else {
                if let nextVC = segue.destination as? NotesDetailViewController {
                    nextVC.detail = self.selectedNoteDetail
                    nextVC.condition = self.condition
                    nextVC.editIndex = self.editIndex
                }
            }
                /*if let nextVC = segue.destination as? NotesDetailViewController {
                    nextVC.detail = self.selectedNoteDetail
                    nextVC.condition = self.condition
                    nextVC.editIndex = self.editIndex
                    */
            }
        /*if let nextVC = segue.destination as? NotesDetailViewController {
            nextVC.detail = self.selectedNoteDetail
            nextVC.condition = self.condition
            nextVC.editIndex = self.editIndex
        }*/
            
        }*/
    
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
        isSearching = true
        self.condition = .add
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
        filteredNoteList = DataSource.shared.noteList.filter({( note : Note) -> Bool in
            return note.detail.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
        }
}
