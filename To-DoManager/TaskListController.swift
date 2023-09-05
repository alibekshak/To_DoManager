//
//  TaskListController.swift
//  To-DoManager
//
//  Created by Apple on 01.09.2023.
//

import UIKit

class TaskListController: UITableViewController {
    
    // Хранилище
    var tasksStorage: TaskStorageProtocol = TaskStorage()
    
    // коллекция задач
    var tasks: [TaskPriority:[TaskProtocol]] = [:]{
        didSet{
            for (tasksGroupPriority, tasksGroup) in tasks{
                    tasks[tasksGroupPriority] = tasksGroup.sorted{task1, task2 in
                        let task1position = tasksStatusPosition.firstIndex(of: task1.status) ?? 0
                        let task2position = tasksStatusPosition.firstIndex(of: task2.status) ?? 0
                        return task1position < task2position
                    }
                }
            }
        }
    
    // отоброжение секций по типам
    var sectionTypesPosition: [TaskPriority] = [.important, .normal]
    
    // порядок отображения задач по их статусу
    var tasksStatusPosition: [TaskStatus] = [.planned, .completed]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTasks()
    }
    
    private func loadTasks(){
        // подготовка коллекции с задачами
        sectionTypesPosition.forEach{ taskType in
            tasks[taskType] = []
        }
        // загрузка и разбор задач из хранилища
        tasksStorage.loadTask().forEach{ task in
            tasks[task.type]?.append(task)
        }
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return tasks.count
    }
    
    // количество строк в определенной секции
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // определяем приоритет задач
        let taskType = sectionTypesPosition[section]
        guard let currentTasksType = tasks[taskType] else{
            return 0
        }
        return currentTasksType.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // ячейка на основе констрейнтов
//        return getConfiguredTaskCell_constraints(for: indexPath)
        
        // ячейка на основе стека
        return getConfiguredTaskCell_stack(for: indexPath)
    }
    
    // ячейка на основе ограничений
    private func getConfiguredTaskCell_stack(for indexPath: IndexPath) -> UITableViewCell{
        // загружаем прототип ячейки по идентификатору
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellStack", for: indexPath) as! TaskCell
        // получаем данные о задаче, которую необходимо вывести в ячейке
        let taskType = sectionTypesPosition[indexPath.section]
        guard let currentTask = tasks[taskType]?[indexPath.row] else {
            return cell
        }
        
        // изменяем текст в ячейке
        cell.title.text = currentTask.title
        // изменяем символ в ячейке
        cell.symbol.text = getSymbolForTask(with: currentTask.status)
        
        // изменяем цвет текста и символа
        if currentTask.status == .planned{
            cell.title.textColor = .black
            cell.symbol.textColor = .black
        }else{
            cell.title.textColor = .lightGray
            cell.symbol.textColor = .lightGray
        }
        return cell
    }
    
    // ячейка на основе ограничений
    private func getConfiguredTaskCell_constraints(for indexPath: IndexPath) -> UITableViewCell{
        // загружаем прототип ячейки по идентификатору
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellConstraints", for: indexPath)
        // получаем данные о задаче, которую необходимо вывести в ячейке
        let taskType = sectionTypesPosition[indexPath.section]
        guard let currentTask = tasks[taskType]?[indexPath.row] else {
            return cell
        }
        
        // текстовая метка символа
        let symbolLabel = cell.viewWithTag(1) as? UILabel
        // текстовая метка названия задачи
        let textLabel = cell.viewWithTag(2) as? UILabel
        
        // изменяем символ в ячейке
        symbolLabel?.text = getSymbolForTask(with: currentTask.status)
        // изменяем текст в ячейке
        textLabel?.text = currentTask.title
        
        // изменяем цвет текста и символа
        if currentTask.status == .planned{
            textLabel?.textColor = .black
            symbolLabel?.textColor = .black
        }else{
            textLabel?.textColor = .lightGray
            symbolLabel?.textColor = .lightGray
        }
        return cell
    }
    
    // возвращаем символ для соответствующего типа задачи
    private func getSymbolForTask(with status: TaskStatus) -> String{
        var resultSymbol: String
        if status == .planned{
            resultSymbol = "\u{25CB}"
        }else if status == .completed{
            resultSymbol = "\u{25C9}"
        }else{
            resultSymbol = ""
        }
        return resultSymbol
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        var title: String?
        let tasksType = sectionTypesPosition[section]
        if tasksType == .important{
            title = "Важные"
        }else if tasksType == .normal{
            title = "Текущие"
        }
        return title
    }
    
    
    // Изменение статуса задачи на «выполнено»
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // проверка существование задачи
        let taskType = sectionTypesPosition[indexPath.section]
        guard let _ = tasks[taskType]?[indexPath.row]else{
            return
        }
        
        guard tasks[taskType]![indexPath.row].status == .planned else{
            // снимаем выделение со строки
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        // Отмечаем задачу как выполненную
        tasks[taskType]![indexPath.row].status = .completed
        // Перезагружаем секцию таблицы
        tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
    }
    
    
    // Изменение статуса задачи на «запланирована»
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let taskType = sectionTypesPosition[indexPath.section]
        guard let _ = tasks[taskType]?[indexPath.row]else{
            return nil
        }
        // проверяем, что задача имеет статус "выполнено"
        guard tasks[taskType]![indexPath.row].status == .completed else{
            return nil
        }
        
        // создаем действие для изменения статуса
        let actionSwipeInstance = UIContextualAction(style: .normal, title: "Не выполнена"){ _,_,_ in
            self.tasks[taskType]![indexPath.row].status = .planned
            self.tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
        }
        return UISwipeActionsConfiguration(actions: [actionSwipeInstance])
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
