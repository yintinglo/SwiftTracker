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
        if let index = expenses.firstIndex(where: { $0.id == expense.id}){
            expenses[index] = expense
            saveExpenses()
        }
    }
    
    func deleteExpense(at offsets: IndexSet) {
        expenses.remove(atOffsets: offsets)
        saveExpenses()
    }
    
    private func saveExpenses(){
        if let encoded = try? JSONEncoder().encode(expenses){
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadExpenses(){
        if let savedExpenses = UserDefaults.standard.data(forKey: saveKey) {
            if let decodedExpenses = try? JSONDecoder().decode([Expense].self, from: savedExpenses) {
                expenses = decodedExpenses
            }
        }
    }
    
}

