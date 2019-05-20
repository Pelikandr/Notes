//
//  TableViewController.swift
//  Notes
//
//  Created by Denis Zayakin on 5/15/19.
//  Copyright © 2019 Denis Zayakin. All rights reserved.
//

import UIKit

class NotesListViewController: UITableViewController {
 
    var selectedNoteDetail: String = ""
    var condition: NoteDetailCondition?
    var editIndex: Int?
    
    @IBAction func addNote(_ sender: Any) {
        condition = .add
        self.performSegue(withIdentifier: "ShowNotesDetailViewController", sender: nil)
    }
    
    @objc func refreshArray() {
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.tableView.reloadData()
        tableView.rowHeight = 75
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:  #selector(refreshArray), for: .valueChanged)
        self.refreshControl = refreshControl
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if DataSource.shared.flag == true
        {
            self.tableView.reloadData()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataSource.shared.noteList.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedNoteDetail = DataSource.shared.noteList[indexPath.row].detail
        condition = .detail
        self.performSegue(withIdentifier: "ShowNotesDetailViewController", sender: nil)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NoteTableViewCell
        let noteListIndex = DataSource.shared.noteList[indexPath.row]
        cell.dateLabel?.text = noteListIndex.date
        cell.timeLabel?.text = noteListIndex.time
        if DataSource.shared.noteList[indexPath.row].detail.count > 100 {
            let index = noteListIndex.detail.index(noteListIndex.detail.startIndex, offsetBy: 100)
            cell.detailLabel?.text = String(noteListIndex.detail[..<index]) + "..."
        } else {
            cell.detailLabel?.text = noteListIndex.detail
        }
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let editAction = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: "Изменить") { (action, indexPath) -> Void in
            self.condition = .edit
            self.editIndex = indexPath.row
            self.performSegue(withIdentifier: "ShowNotesDetailViewController", sender: nil)
            
        }
        editAction.backgroundColor = UIColor.orange
        let deleteAction = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: "Удалить") { (action, indexPath) -> Void in
            DataSource.shared.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        return [deleteAction, editAction]
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    /*
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            DataSource.shared.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
 */
    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextVC = segue.destination as? NotesDetailViewController {
            nextVC.detail = self.selectedNoteDetail
            nextVC.condition = self.condition
            nextVC.editIndex = self.editIndex //DataSource.shared.noteIndex
        }
    }
}

/*
 func getCurrentTime(date: String, time: String) {
 let dateValue = Date()
 let formatter = DateFormatter()
 let formatter2 = DateFormatter()
 formatter.dateFormat = "dd.MM"
 formatter2.dateFormat = "HH:mm:ss"
 let time = formatter.string(from: dateValue)
 let date = formatter2.string(from: dateValue)
 print (time)
 print (date)
 }
 */
