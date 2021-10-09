//
//  AlertController.swift
//  RealmApp
//
//  Created by Alexey Efimov on 12.03.2020.
//  Copyright © 2020 Alexey Efimov. All rights reserved.
//

/// Custom UIAlerController
/// Available two controllers: for saving new data, and for updating data
import UIKit

class AlertController: UIAlertController {
    var doneButton = "Save"
    
    static func createAlert(withTitle title: String, andMessage message: String) -> AlertController {
        AlertController(title: title, message: message, preferredStyle: .alert)
    }
        
    func action(with taskList: TaskList?, completion: @escaping (String) -> Void) {
        
        if taskList != nil { doneButton = "Update" }
                
        let saveAction = UIAlertAction(title: doneButton, style: .default) { _ in
            guard let newValue = self.textFields?.first?.text else { return }
            guard !newValue.isEmpty else { return }
            completion(newValue)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        addAction(saveAction)
        addAction(cancelAction)
        addTextField { textField in
            textField.placeholder = "List Name"
            textField.text = taskList?.name
        }
    }
    
    func action(with task: Task?, completion: @escaping (String, String) -> Void) {
        if task != nil { doneButton = "Update" }
        
        let saveAction = UIAlertAction(title: doneButton, style: .default) { _ in
            guard let newTask = self.textFields?.first?.text else { return }
            guard !newTask.isEmpty else { return }
            
            if let note = self.textFields?.last?.text, !note.isEmpty {
                completion(newTask, note)
            } else {
                completion(newTask, "")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        addAction(saveAction)
        addAction(cancelAction)
        
        addTextField { textField in
            textField.placeholder = "New task"
            textField.text = task?.name
        }
        
        addTextField { textField in
            textField.placeholder = "Note"
            textField.text = task?.note
        }
    }
    
//    func action(completion: @escaping (String, String) -> Void) {
//
//        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
//            guard let newTask = self.textFields?.first?.text else { return }
//            guard !newTask.isEmpty else { return }
//
//            if let note = self.textFields?.last?.text, !note.isEmpty {
//                completion(newTask, note)
//            } else {
//                completion(newTask, "")
//            }
//        }
//
//        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
//
//        addAction(saveAction)
//        addAction(cancelAction)
//
//        addTextField { textField in
//            textField.placeholder = "New task"
//        }
//
//        addTextField { textField in
//            textField.placeholder = "Note"
//        }
//    }
}
