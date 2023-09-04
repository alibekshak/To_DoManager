import Foundation
import UIKit

protocol TaskStorageProtocol{
    func loadTask() -> [TaskProtocol]
    func saveTask(_ tasks: [TaskProtocol])
}


class TaskStorage: TaskStorageProtocol{
    func loadTask() -> [TaskProtocol] {
        let testTask: [TaskProtocol] = [
            Task(title: "Купить хлеб", type: .normal, status: .planned),
            Task(title: "Помыть кота", type: .important, status: .planned),
            Task(title: "Отдать долг", type: .important, status: .completed),
            Task(title: "Купить новый пылесос", type: .normal, status: .completed),
            Task(title: "Позвонить родителям", type: .important, status: .planned),
            Task(title: "Купить мыло", type: .normal, status: .planned)
        ]
        return testTask
    }
    func saveTask(_ tasks: [TaskProtocol]) {}
}
