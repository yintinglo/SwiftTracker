import SwiftUI
import Charts

struct ExpenseSummaryView: View {
    @StateObject var viewModel = ExpenseViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                // display total expenses by category
                Chart {
                    ForEach(viewModel.expensesByCategory, id: \.category) { dataPoint in
                        BarMark(
                            x: .value("Category", dataPoint.category.rawValue),
                            y: .value("Total", dataPoint.total)
                        )
                        .foregroundStyle(by: .value("Category", dataPoint.category.rawValue))
                    }
                }
                .padding()
                .frame(height: 300)
                
                // display individual expenses
                List {
                    ForEach(viewModel.expenses) { expense in
                        VStack(alignment: .leading) {
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
                .navigationTitle("SwiftSpendings:")
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
}

// ViewModel extension to calculate expenses by category
extension ExpenseViewModel {
    var expensesByCategory: [ExpenseCategoryData] {
        let grouped = Dictionary(grouping: expenses, by: { $0.category })
        return grouped.map { category, expenses in
            ExpenseCategoryData(category: category, total: expenses.reduce(0) { $0 + $1.amount })
        }
    }
}

//category data for the chart
struct ExpenseCategoryData {
    let category: ExpenseCategory
    let total: Double
}

