import SwiftUI

struct AddEditExpenseView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: ExpenseViewModel
    @State private var name: String = ""
    @State private var amount: String = ""
    @State private var category: ExpenseCategory = .food
    @State private var date = Date()
    
    var expenseToEdit: Expense?
    
    var body: some View {
        Form {
            Section(header: Text("Expense Details")) {
                TextField("Name", text: $name)
                TextField("Amount", text: $amount)
                    .onChange(of: amount) {newValue in
                        amount = newValue.filter {"0123456789.".contains($0) }
                    }
                
                Picker("Category", selection: $category) {
                    ForEach(ExpenseCategory.allCases) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                DatePicker("Date", selection: $date, displayedComponents: .date)
            }
        }
        .navigationTitle(expenseToEdit == nil ? "Add Expense" : "Edit Expense")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: saveExpense) {
                    Text("Save")
                }
            }
        }
        .onAppear() {
            if let expense = expenseToEdit {
                name = expense.name
                amount = String(expense.amount)
                category = expense.category
                date = expense.date
            }
        }
    }
    private func saveExpense() {
        guard let amountValue = Double(amount) else { return }
        let newExpense = Expense(name: name, amount: amountValue, category: category, date: date)
        
        if let expenses = expenseToEdit {
            viewModel.editExpense(newExpense)
        } else {
            viewModel.addExpense(newExpense)
        }
        presentationMode.wrappedValue.dismiss()
    }
}
