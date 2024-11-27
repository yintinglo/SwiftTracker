import SwiftUI

struct ExpenseSummaryView: View {
    @StateObject var viewModel = ExpenseViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.expenses) { expense in
                    VStack(alignment: .leading){
                        Text(expense.name)
                            .font(.headline)
                        Text("\(expense.category.rawValue) - $\(expense.amount, specifier: "%.2f")")
                            .font(.subheadline)
                        Text(expense.date, style: .date)
                            .font(.caption)
                    }
                }
                .onDelete(perform: viewModel.deleteExpense)
            }
            .navigationTitle("Expenses")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    NavigationLink(destination: AddEditExpenseView(viewModel: viewModel)) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}
