import SwiftUI
import Foundation

class ExpenseViewModel: ObservableObject {
    @Published var expenses: [Expense] = []
    
    private let saveKey = "SavedExpenses"
    
    init() {
        loadExpenses()
    }
    
    func addExpense(_ expense: Expense) {
        expenses.append(expense)
        saveExpenses()
    }
    
    func editExpense(_ expense: Expense) {
        if let index = expenses.firstIndex(where: { $0.id == expense.id }) {
            expenses[index] = expense
            saveExpenses()
        }
    }
    
    func deleteExpense(at offsets: IndexSet) {
        expenses.remove(atOffsets: offsets)
        saveExpenses()
    }
    
    private func saveExpenses() {
        if let encoded = try? JSONEncoder().encode(expenses) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadExpenses() {
        if let savedExpenses = UserDefaults.standard.data(forKey: saveKey) {
            if let decodedExpenses = try? JSONDecoder().decode([Expense].self, from: savedExpenses) {
                expenses = decodedExpenses
            }
        }
    }
    
    var totalAmount: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    var expenseByCategory: [ExpenseCategoryData] {
        expenses
            .reduce(into: [:]) { result, expense in
                result[expense.category, default: 0] += expense.amount
            }
            .map { ExpenseCategoryData(category: $0.key, total: $0.value) }
            .sorted { $0.category.rawValue < $1.category.rawValue }
    }
    
    var expenseByDate: [Date: Double] {
        expenses.reduce(into: [:]) { result, expense in
            let day = Calendar.current.startOfDay(for: expense.date)
            result[day, default: 0] += expense.amount
        }
    }
    
    func expenses(for dateRange: ClosedRange<Date>) -> [Expense] {
        expenses.filter { dateRange.contains($0.date) }
    }
}

