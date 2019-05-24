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
    
    var note: Note?
    var condition: NoteDetailCondition = .detail
    var editIndex: Int?
    
    var filteredNoteList = DataSource.shared.filteredNoteList
    var isSearching = DataSource.shared.isSearching
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        noteDetailTextView.text = note?.detail
        
        switch condition {
        case .detail:
            noteDetailTextView.isEditable = false
            
        case .add:
            let saveButton = UIBarButtonItem.init(title: "Сохранить", style: .plain, target: self, action: #selector(save))
            self.navigationItem.rightBarButtonItem = saveButton
            
        case .edit:
//            if DataSource.shared.isSearching{
//                detail = DataSource.shared.filteredNoteList[editIndex!].detail
//                noteDetailTextView.text = note?.detail
//            } else {
//                detail = DataSource.shared.noteList[editIndex!].detail
//                noteDetailTextView.text = note?.detail
//            }
            let editButton = UIBarButtonItem.init(title: "Изменить", style: .plain, target: self, action: #selector(edit))
            self.navigationItem.rightBarButtonItem = editButton
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.noteDetailTextView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func save()
    {
        if noteDetailTextView.text != "" {
            let note = Note(id: UUID().uuidString, date: Date(), detail: noteDetailTextView.text)
            DataSource.shared.append(note: note)
            self.navigationController?.popViewController(animated: true)
            DataSource.shared.toReloadTableview = true
        } else {
            let alertController = UIAlertController(title: "Ошибка", message: "Заметка не может быть пустой", preferredStyle: .alert)
            self.present(alertController, animated: true, completion: nil)
            let when = DispatchTime.now() + 2
            DispatchQueue.main.asyncAfter(deadline: when) {
                alertController.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @objc func edit()
    {
//        newNote?.detail = noteDetailTextView.text
//        if isSearching{
//            let editId = DataSource.shared.filteredNoteList[editIndex!].id
//            DataSource.shared.editInfilteredNoteList(at: editIndex!, editedNote: newNote!)
//            for i in 0...DataSource.shared.noteList.count-1{
//                if editId == DataSource.shared.noteList[i].id {
//                    DataSource.shared.editInNoteList(at: i, editedNote: newNote!)
//                    break
//                }
//            }
//        } else {
//            DataSource.shared.editInNoteList(at: editIndex!, editedNote: newNote!)
//        }
//        self.navigationController?.popViewController(animated: true)
//        DataSource.shared.toReloadTableview = true
    }
    
    @IBAction func share(_ sender: UIView) {
        let textToShare = noteDetailTextView.text
        let activityVC = UIActivityViewController(activityItems: [textToShare as Any] , applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
        self.present(activityVC, animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        
        if let keyboardSize = keyboardSize, let animationDuration = animationDuration {
            UIView.animate(withDuration: animationDuration) {
                self.view.frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - keyboardSize.height))
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        
        if let animationDuration = animationDuration {
            UIView.animate(withDuration: animationDuration) {
                self.view.frame = CGRect(origin: .zero, size: UIScreen.main.bounds.size)
            }
        }
    }
}

