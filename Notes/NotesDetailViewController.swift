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
    @IBOutlet weak var actionButton: UIBarButtonItem!
    
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
            actionButton.title = "Редактировать"
            
        case .add:
            actionButton.title = "Сохранить"
            
        case .edit:
            actionButton.title = "Изменить"
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
    
    @IBAction func actionButtonTapped(_ sender: Any) {
        switch condition {
        case .detail:
            noteDetailTextView.isEditable = true
            noteDetailTextView.becomeFirstResponder()
            actionButton.title = "Изменить"
            condition = .edit
            
        case .add, .edit:
            if noteDetailTextView.text != "" {
                if let id = note?.id {
                    let editedNote = Note(id: id, date: Date(), detail: noteDetailTextView.text)
                    DataSource.shared.update(editedNote)
                } else {
                    let note = Note(id: UUID().uuidString, date: Date(), detail: noteDetailTextView.text)
                    DataSource.shared.append(note: note)
                }
                self.navigationController?.popViewController(animated: true)
                DataSource.shared.toReloadTableview = true
            } else {
                showNoTextError()
            }
        }
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
    
    func showNoTextError() {
        let alertController = UIAlertController(title: "Ошибка", message: "Заметка не может быть пустой", preferredStyle: .alert)
        self.present(alertController, animated: true, completion: nil)
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when) {
            alertController.dismiss(animated: true, completion: nil)
        }
    }
}

