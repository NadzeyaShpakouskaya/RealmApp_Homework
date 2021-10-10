//
//  TasksViewController.swift
//  RealmApp
//
//  Created by Alexey Efimov on 02.07.2018.
//  Copyright © 2018 Alexey Efimov. All rights reserved.
//

import RealmSwift

class TasksViewController: UITableViewController {
        // MARK: - Public properties
    var taskList: TaskList!
    
        // MARK: - Private properties
    private var currentTasks: Results<Task>!
    private var completedTasks: Results<Task>!
    
        // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        prepareData()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? currentTasks.count : completedTasks.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "CURRENT TASKS" : "COMPLETED TASKS"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TasksCell", for: indexPath)
        let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.name
        content.secondaryText = task.note
        cell.contentConfiguration = content
        return cell
    }
    
    @objc private func addButtonPressed() {
        showAlert()
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.shared.delete(task)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { _, _, isDone in
            self.showAlert(task) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            isDone(true)
        }
        
        let doneAction = UIContextualAction(style: .normal, title: "Done") {_, _, isDone in
            self.moveTask(task, from: indexPath)
            isDone(true)
            
        }
        
        let undoneAction = UIContextualAction(style: .normal, title: "Undone") {_, _, isDone in
            self.moveTask(task, from: indexPath)
            isDone(true)
        }
        
        editAction.backgroundColor = .orange
        doneAction.backgroundColor = .systemGreen
        undoneAction.backgroundColor = .blue
        
        let actions = indexPath.section == 0 ?
        [doneAction, editAction, deleteAction] :
        [undoneAction, editAction, deleteAction]
        
        return UISwipeActionsConfiguration(actions: actions)
        
        
    }
    
    private func prepareUI() {
        title = taskList.name
        
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonPressed)
        )
        navigationItem.rightBarButtonItems = [addButton, editButtonItem]
    }
    
    private func prepareData() {
        currentTasks = taskList.tasks.filter("isComplete = false")
        completedTasks = taskList.tasks.filter("isComplete = true")
    }
    
    private func moveTask(_ task: Task, from indexPath: IndexPath) {
        StorageManager.shared.toggleTaskToComplete(task)
        
        let destination = indexPath.section == 0 ?
        IndexPath(row: self.completedTasks.count - 1, section: 1) :
        IndexPath(row: self.currentTasks.count - 1, section: 0)
        
        tableView.moveRow(at: indexPath, to: destination)
    }
}

    // MARK: - AlertController Usage
extension TasksViewController {
    
    private func showAlert(_ task: Task? = nil, completion: (() -> Void)? = nil) {
        guard let task = task, let completion = completion else {
            let alert = AlertController.createAlert(
                withTitle: "New Task",
                andMessage: "What do you want to do?"
            )
            
            alert.action(with: nil) { newValue, note in
                self.saveTask(withName: newValue, andNote: note)
            }
            
            present(alert, animated: true)
            return
        }
        
        let alert = AlertController.createAlert(
            withTitle: "Change Task",
            andMessage: "Update task description"
        )
        
        alert.action(with: task) {value, note in
            StorageManager.shared.edit(task, newValue: value, newNote: note)
            completion()
        }
        present(alert, animated: true)
    }
    
    private func saveTask(withName name: String, andNote note: String) {
        let task = Task(value: [name, note])
        StorageManager.shared.save(task, to: taskList)
        let rowIndex = IndexPath(row: currentTasks.index(of: task) ?? 0, section: 0)
        tableView.insertRows(at: [rowIndex], with: .automatic)
    }
}

