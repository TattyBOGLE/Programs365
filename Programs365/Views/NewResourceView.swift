import SwiftUI

struct NewResourceView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var resourceManager = CoachResourceManager.shared
    @State private var title = ""
    @State private var description = ""
    @State private var category = ""
    @State private var urlString = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Resource Details")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                    TextField("Category", text: $category)
                    TextField("URL", text: $urlString)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                }
            }
            .navigationTitle("New Resource")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveResource()
                    }
                    .disabled(title.isEmpty || description.isEmpty || category.isEmpty || urlString.isEmpty)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func saveResource() {
        guard let url = URL(string: urlString) else {
            errorMessage = "Please enter a valid URL"
            showingError = true
            return
        }
        
        let resource = CoachResource(
            title: title,
            description: description,
            category: category,
            url: url
        )
        
        resourceManager.resources.append(resource)
        dismiss()
    }
}

#Preview {
    NewResourceView()
} 