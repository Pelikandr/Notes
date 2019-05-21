//
//  ViewController.swift
//  Notes
//
//  Created by Denis Zayakin on 5/15/19.
//  Copyright © 2019 Denis Zayakin. All rights reserved.
//

import UIKit

enum NoteDetailCondition {
    case detail
    case add
    case edit
}

class NotesDetailViewController: UIViewController {

    @IBOutlet weak var noteDetailTextView: UITextView!
    
    var detail: String = ""
    var newNote = Note()
    var condition: NoteDetailCondition?
    var editIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newNote?.detail = ""

        switch condition {
        case .detail?: do {
            noteDetailTextView.text = detail
            noteDetailTextView.isEditable = false
            }
        case .add?: do {
            let saveButton =  UIBarButtonItem(image: UIImage(named: "imagename"), style: .plain, target: self, action:#selector(self.save(_:)) )
            saveButton.title = "Сохранить"
            self.navigationItem.rightBarButtonItem  = saveButton
            }
        case .edit?: do {
            detail = DataSource.shared.noteList[editIndex!].detail
            noteDetailTextView.text = detail
            let editButton =  UIBarButtonItem(image: UIImage(named: "imagename"), style: .plain, target: self, action:#selector(self.edit(_:)) )
            editButton.title = "Изменить"
            self.navigationItem.rightBarButtonItem  = editButton
            noteDetailTextView.text = detail
            }
        case .none: print("Condition none")
        }
    }
    
    @objc func save(_ sender:UIBarButtonItem!)
    {
        if noteDetailTextView.text != "" {
            newNote?.detail = noteDetailTextView.text
            DataSource.shared.append(note:newNote!)
            self.navigationController?.popViewController(animated: true)
            DataSource.shared.toReloadTableview = true
        } else {
            let alertController = UIAlertController(title: "Ошибка", message: "Заметка не может быть пустой", preferredStyle: .alert)
            self.present(alertController, animated: true, completion: nil)
            let when = DispatchTime.now() + 2
            DispatchQueue.main.asyncAfter(deadline: when){
                alertController.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @objc func edit(_ sender:UIBarButtonItem!)
    {
        newNote?.detail = noteDetailTextView.text
        DataSource.shared.edit(at: editIndex!, editedNote: newNote!)
        self.navigationController?.popViewController(animated: true)
        DataSource.shared.toReloadTableview = true
    }
    
    @IBAction func share(_ sender: UIView) {
        let textToShare = noteDetailTextView.text
        let activityVC = UIActivityViewController(activityItems: [textToShare as Any] , applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
        self.present(activityVC, animated: true, completion: nil)
    }
}

