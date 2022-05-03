

import UIKit
import CoreData

class TasksViewController: UITableViewController {
    
    private let cellID = "cell"
    
    let dataManager = DataManager()
    
    private var context: NSManagedObjectContext!
    
    private var tasks: [Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        context = dataManager.persistentContainer.viewContext
        
        setupTableView()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchData()
    }
    
    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
    }
    
    private func setupNavigationBar() {
        title = "Do it list"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        navigationBarAppearance.backgroundColor = UIColor(red: 105/255, green: 200/255, blue: 105/255, alpha: 0.9)
        
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewTask))
        navigationItem.rightBarButtonItem?.tintColor = .black
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(deleteAllTasks))
        navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    @objc func addNewTask() {
        showAlertAdd()
    }
    
    @objc func deleteAllTasks() {
        showAlertDelete()
    }
    
    private func showAlertAdd() {
        let alert = UIAlertController(title: "Новая задача", message: "Просто создай задачу", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Сохранить", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            self.save(taskName: task)
        }
        let cancelAction = UIAlertAction(title: "Отменить", style: .destructive)
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func showAlertDelete() {
        let alert = UIAlertController(title: "Внимание !", message: "Вы действительно хотите удалить все задачи ?", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Да", style: .default) { _ in
            self.totalDelete()
        }
        let cancelAction = UIAlertAction(title: "Нет", style: .destructive)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func fetchData() {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        do {
            tasks = try context.fetch(fetchRequest)
            tableView.reloadData()
        } catch let error  {
            print(error)
        }
    }
    
    private func save(taskName: String) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: context) else { return }
        guard let task = NSManagedObject(entity: entityDescription, insertInto: context) as? Task else { return }
        
        task.name = taskName
        tasks.append(task)
        
        let cellIndex = IndexPath(row: tasks.count - 1, section: 0)
        tableView.insertRows(at: [cellIndex], with: .automatic)
        
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                print(error)
            }
        }
        dismiss(animated: true)
    }
    
    private func totalDelete() {
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch let error {
            print(error)
        }
        tasks.removeAll()
        tableView.reloadData()
    }
    
}

extension TasksViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let index = tasks[indexPath.row]
        if editingStyle == .delete {
            context.delete(index)
            do {
                try context.save()
            } catch let error {
                print(error)
            }
        }
        self.fetchData()
    }
    
}
