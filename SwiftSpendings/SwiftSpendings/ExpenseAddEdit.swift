import SwiftUI

// This struct represents the view for adding or editing an expense.
struct AddEditExpenseView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: ExpenseViewModel
    @State private var name: String = "" // Name of the expense
    @State private var amount: String = "" // Amount of the expense (as a String for easier text editing)
    @State private var category: ExpenseCategory = .food // Default category for the expense
    @State private var date = Date() // Date of the expense

    // Optional parameter to edit an existing expense (if provided)
    var expenseToEdit: Expense?
    
    var body: some View {
        // Form layout for user input
        Form {
            // Section for entering expense details
            Section(header: Text("Expense Details")) {
                // TextField for the expense name
                TextField("Name", text: $name)
                // TextField for the amount, restricting input to digits and period
                TextField("Amount", text: $amount)
                    .onChange(of: amount) {newValue in
                        amount = newValue.filter {"0123456789.".contains($0) }
                    }
                // Picker for selecting the expense category
                Picker("Category", selection: $category) {
                    // Iterate over all expense categories to create the picker options
                    ForEach(ExpenseCategory.allCases) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                // DatePicker for selecting the date of the expense
                DatePicker("Date", selection: $date, displayedComponents: .date)
            }
        }
        // Set the navigation title based on whether we're adding or editing an expense
        .navigationTitle(expenseToEdit == nil ? "Add Expense" : "Edit Expense")
        // Toolbar with a "Save" button that triggers the saveExpense function
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: saveExpense) {
                    Text("Save")
                }
            }
        }
        // When the view appears, load the current values if editing an existing expense
        .onAppear() {
            if let expense = expenseToEdit {
                name = expense.name // Pre-fill name
                amount = String(expense.amount) // Pre-fill amount (converted to string)
                category = expense.category // Pre-fill category
                date = expense.date // Pre-fill date
            }
        }
    }
    // Function to save the expense (either add new or update existing)
    private func saveExpense() {
        // Ensure the amount is a valid double before saving
        guard let amountValue = Double(amount) else { return }
        // Create a new Expense object with the provided details
        let newExpense = Expense(name: name, amount: amountValue, category: category, date: date)
        // If editing an existing expense, update it; otherwise, add the new expense
        if let expenses = expenseToEdit {
            viewModel.editExpense(newExpense)
        } else {
            viewModel.addExpense(newExpense)
        }
        presentationMode.wrappedValue.dismiss()
    }
}
