import SwiftUI

// Remove ProgramCardView import since it's part of the main app target
public struct SavedProgramsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var programManager = SavedProgramManager.shared
    @State private var searchText = ""
    @State private var selectedFilter = "All"
    @State private var showingNewProgram = false
    @State private var showingDeleteConfirmation = false
    @State private var programToDelete: SavedProgram?
    @State private var showingShareSheet = false
    @State private var selectedProgram: SavedProgram?
    @State private var showingEditSheet = false
    @State private var showingSortOptions = false
    @State private var sortOption = "Date"
    
    let filters = ["All", "Track", "Field", "Para", "Custom"]
    let sortOptions = ["Date", "Name", "Category", "Duration"]
    
    var filteredPrograms: [SavedProgram] {
        var programs = programManager.savedPrograms
        
        // Apply search filter
        if !searchText.isEmpty {
            programs = programs.filter { program in
                program.name.localizedCaseInsensitiveContains(searchText) ||
                program.category.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply category filter
        if selectedFilter != "All" {
            programs = programs.filter { $0.category.rawValue == selectedFilter }
        }
        
        // Apply sorting
        switch sortOption {
        case "Date":
            programs.sort { $0.dateCreated > $1.dateCreated }
        case "Name":
            programs.sort { $0.name < $1.name }
        case "Category":
            programs.sort { $0.category.rawValue < $1.category.rawValue }
        case "Duration":
            programs.sort { $0.weeks.count < $1.weeks.count }
        default:
            break
        }
        
        return programs
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter Bar
                VStack(spacing: 12) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search programs", text: $searchText)
                            .foregroundColor(.white)
                        
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(10)
                    
                    // Filter and Sort Buttons
                    HStack {
                        Button(action: { showingSortOptions = true }) {
                            HStack {
                                Image(systemName: "arrow.up.arrow.down")
                                Text("Sort")
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(20)
                        }
                        
                        Spacer()
                        
                        Button(action: { showingNewProgram = true }) {
                            HStack {
                                Image(systemName: "plus.circle")
                                Text("New Program")
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.red)
                            .cornerRadius(20)
                        }
                    }
                }
                .padding()
                .background(Color.black)
                
                // Programs List
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredPrograms) { program in
                            ProgramCard(program: program)
                                .onTapGesture {
                                    selectedProgram = program
                                    showingEditSheet = true
                                }
                                .contextMenu {
                                    Button(action: {
                                        selectedProgram = program
                                        showingShareSheet = true
                                    }) {
                                        Label("Share", systemImage: "square.and.arrow.up")
                                    }
                                    
                                    Button(role: .destructive, action: {
                                        programToDelete = program
                                        showingDeleteConfirmation = true
                                    }) {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Saved Programs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.red)
                    }
                }
            }
            .sheet(isPresented: $showingNewProgram) {
                NewProgramView()
            }
            .sheet(isPresented: $showingEditSheet) {
                if let program = selectedProgram {
                    EditProgramView(program: program)
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let program = selectedProgram {
                    ShareSheet(activityItems: ["Check out my program: \(program.name)"])
                }
            }
            .actionSheet(isPresented: $showingDeleteConfirmation) {
                ActionSheet(
                    title: Text("Delete Program"),
                    message: Text("Are you sure you want to delete this program?"),
                    buttons: [
                        .destructive(Text("Delete")) {
                            if let program = programToDelete {
                                programManager.deleteProgram(program)
                            }
                        },
                        .cancel()
                    ]
                )
            }
            .actionSheet(isPresented: $showingSortOptions) {
                ActionSheet(
                    title: Text("Sort By"),
                    buttons: sortOptions.map { option in
                        .default(Text(option)) {
                            sortOption = option
                        }
                    } + [.cancel()]
                )
            }
        }
    }
}

struct NewProgramView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var programManager = SavedProgramManager.shared
    @State private var name = ""
    @State private var category = SavedProgram.ProgramCategory.sprints
    @State private var weeks: [String] = []
    @State private var description = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Program Details")) {
                    TextField("Name", text: $name)
                    Picker("Category", selection: $category) {
                        ForEach(SavedProgram.ProgramCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    TextEditor(text: $description)
                        .frame(height: 100)
                }
            }
            .navigationTitle("New Program")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newProgram = SavedProgram(
                            name: name,
                            description: description,
                            category: category,
                            weeks: weeks
                        )
                        programManager.addProgram(newProgram)
                        dismiss()
                    }
                    .disabled(name.isEmpty || description.isEmpty)
                }
            }
        }
    }
}

struct EditProgramView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var programManager = SavedProgramManager.shared
    let program: SavedProgram
    @State private var editedName: String
    @State private var editedCategory: SavedProgram.ProgramCategory
    @State private var editedWeeks: [String]
    @State private var editedDescription: String
    
    init(program: SavedProgram) {
        self.program = program
        _editedName = State(initialValue: program.name)
        _editedCategory = State(initialValue: program.category)
        _editedWeeks = State(initialValue: program.weeks)
        _editedDescription = State(initialValue: program.description)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Program Details")) {
                    TextField("Name", text: $editedName)
                    Picker("Category", selection: $editedCategory) {
                        ForEach(SavedProgram.ProgramCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    TextEditor(text: $editedDescription)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Edit Program")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let updatedProgram = SavedProgram(
                            id: program.id,
                            name: editedName,
                            description: editedDescription,
                            category: editedCategory,
                            weeks: editedWeeks,
                            dateCreated: program.dateCreated
                        )
                        programManager.saveProgram(updatedProgram)
                        dismiss()
                    }
                    .disabled(editedName.isEmpty || editedDescription.isEmpty)
                }
            }
        }
    }
} 