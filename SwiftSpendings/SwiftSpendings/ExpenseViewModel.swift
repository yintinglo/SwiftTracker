import SwiftUI
import Foundation

// ViewModel class to manage and manipulate expenses
class ExpenseViewModel: ObservableObject {
    @Published var expenses: [Expense] = [] // List of all expenses, marked with @Published for SwiftUI updates

    private let saveKey = "SavedExpenses" // Key used for saving and retrieving data from UserDefaults

    init() {
        loadExpenses() // Load saved expenses when the ViewModel is initialized
    }

    // Adds a new expense to the list and saves it to UserDefaults
    func addExpense(_ expense: Expense) {
        expenses.append(expense)
        saveExpenses() // Save updated expenses to UserDefaults
    }

    // Edits an existing expense and saves the changes
    func editExpense(_ expense: Expense) {
        if let index = expenses.firstIndex(where: { $0.id == expense.id }) { // Find the expense by ID
            expenses[index] = expense // Update the expense at the found index
            saveExpenses() // Save updated expenses to UserDefaults
        }
    }

    // Deletes expenses at specified indices and saves the changes
    func deleteExpense(at offsets: IndexSet) {
        expenses.remove(atOffsets: offsets) // Remove expenses at the specified offsets
        saveExpenses() // Save updated expenses to UserDefaults
    }

    // Saves the current list of expenses to UserDefaults as encoded JSON data
    private func saveExpenses() {
        if let encoded = try? JSONEncoder().encode(expenses) { // Encode expenses into JSON format
            UserDefaults.standard.set(encoded, forKey: saveKey) // Save encoded data to UserDefaults
        }
    }

    // Loads saved expenses from UserDefaults and decodes them into the expenses array
    private func loadExpenses() {
        if let savedExpenses = UserDefaults.standard.data(forKey: saveKey) { // Retrieve saved data from UserDefaults
            if let decodedExpenses = try? JSONDecoder().decode([Expense].self, from: savedExpenses) { // Decode JSON data
                expenses = decodedExpenses // Update the expenses array with decoded data
            }
        }
    }

    // Calculates the total amount of all expenses
    var totalAmount: Double {
        expenses.reduce(0) { $0 + $1.amount } // Sum up the amounts of all expenses
    }

    // Groups expenses by their category and calculates the total for each category
    var expenseByCategory: [ExpenseCategoryData] {
        expenses
            .reduce(into: [:]) { result, expense in
                result[expense.category, default: 0] += expense.amount // Add up amounts for each category
            }
            .map { ExpenseCategoryData(category: $0.key, total: $0.value) } // Map to a structured data type
            .sorted { $0.category.rawValue < $1.category.rawValue } // Sort by category name
    }

    // Groups expenses by date and calculates the total amount for each day
    var expenseByDate: [Date: Double] {
        expenses.reduce(into: [:]) { result, expense in
            let day = Calendar.current.startOfDay(for: expense.date) // Get the start of the day for each expense date
            result[day, default: 0] += expense.amount // Add up amounts for each day
        }
    }

    // Filters expenses that fall within a specified date range
    func expenses(for dateRange: ClosedRange<Date>) -> [Expense] {
        expenses.filter { dateRange.contains($0.date) } // Include expenses whose dates are within the range
    }
}
