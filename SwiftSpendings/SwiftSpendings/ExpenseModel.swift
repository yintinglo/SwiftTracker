import Foundation

enum ExpenseCategory: String, CaseIterable, Identifiable, Codable {
    case  food = "Food"
    case transportation = "Transportation"
    case entertainment = "Entertainment"
    case other = "Other"
    
    var id: String {self.rawValue}
}

struct Expense: Identifiable, Codable {
    var id = UUID()
    var name: String
    var amount: Double
    var category: ExpenseCategory
    var date: Date
}
