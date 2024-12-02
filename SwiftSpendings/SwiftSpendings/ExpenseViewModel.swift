import SwiftUI
import Foundation

// ViewModel class to manage and manipulate expenses
class ExpenseViewModel: ObservableObject {
    @Published var expenses: [Expense] = [] // List of all expenses, marked with @Published for SwiftUI updates

    private let saveKey = "SavedExpenses" // Key used for saving and retrieving data from UserDefaults

    init() {
        loadExpenses() // Load saved expenses when ViewModel is initialized
    }

    // Adds new expense to the list & saves to UserDefaults
    func addExpense(_ expense: Expense) {
        expenses.append(expense)
        saveExpenses()
    }

    // Edits existing expense & saves changes
    func editExpense(_ expense: Expense) {
        if let index = expenses.firstIndex(where: { $0.id == expense.id }) { // Find expense by ID
            expenses[index] = expense // Update expense at found index
            saveExpenses() 
        }
    }

    // Deletes expenses at specified indices & saves changes
    func deleteExpense(at offsets: IndexSet) {
        expenses.remove(atOffsets: offsets) // Remove expenses at specified offsets
        saveExpenses()
    }

    // Saves current list of expenses to UserDefaults
    private func saveExpenses() {
        if let encoded = try? JSONEncoder().encode(expenses) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }

    // Loads saved expenses from UserDefaults & decodes into expenses array
    private func loadExpenses() {
        if let savedExpenses = UserDefaults.standard.data(forKey: saveKey) { // Retrieve saved data from UserDefaults
            if let decodedExpenses = try? JSONDecoder().decode([Expense].self, from: savedExpenses) {
                expenses = decodedExpenses // Update the expenses array with decoded data
            }
        }
    }

    // Calculates total amount of expenses
    var totalAmount: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }

    // Groups expenses by category & calculates the total for each category
    var expenseByCategory: [ExpenseCategoryData] {
        expenses
            .reduce(into: [:]) { result, expense in
                result[expense.category, default: 0] += expense.amount // Add up amounts for each category
            }
            .map { ExpenseCategoryData(category: $0.key, total: $0.value) } // Map to a structured data type
            .sorted { $0.category.rawValue < $1.category.rawValue } // Sort by category name
    }

    // Groups expenses by date & calculates total amount for each day
    var expenseByDate: [Date: Double] {
        expenses.reduce(into: [:]) { result, expense in
            let day = Calendar.current.startOfDay(for: expense.date) // Get start of the day for each expense date
            result[day, default: 0] += expense.amount
        }
    }

    // Filters expenses that fall within a specified date range
    func expenses(for dateRange: ClosedRange<Date>) -> [Expense] {
        expenses.filter { dateRange.contains($0.date) } // Include expenses with dates within range
    }
}
