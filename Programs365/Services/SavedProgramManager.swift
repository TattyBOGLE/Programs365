import Foundation
import SwiftUI

public class SavedProgramManager: ObservableObject {
    public static let shared = SavedProgramManager()
    @Published public var savedPrograms: [SavedProgram] = []
    private let savedProgramsKey = "savedPrograms"
    
    private init() {
        loadSavedPrograms()
    }
    
    private func loadSavedPrograms() {
        if let data = UserDefaults.standard.data(forKey: savedProgramsKey) {
            if let decoded = try? JSONDecoder().decode([SavedProgram].self, from: data) {
                savedPrograms = decoded.sorted(by: { $0.dateCreated > $1.dateCreated })
                return
            }
        }
        savedPrograms = []
    }
    
    private func saveToDisk() {
        if let encoded = try? JSONEncoder().encode(savedPrograms) {
            UserDefaults.standard.set(encoded, forKey: savedProgramsKey)
        }
    }
    
    public func addProgram(_ program: SavedProgram) {
        savedPrograms.append(program)
        saveToDisk()
    }
    
    public func deleteProgram(_ program: SavedProgram) {
        savedPrograms.removeAll { $0.id == program.id }
        saveToDisk()
    }
    
    public func saveProgram(_ program: SavedProgram) {
        if let index = savedPrograms.firstIndex(where: { $0.id == program.id }) {
            savedPrograms[index] = program
        } else {
            addProgram(program)
        }
        saveToDisk()
    }
    
    func getPrograms(ofCategory category: SavedProgram.ProgramCategory) -> [SavedProgram] {
        return savedPrograms.filter { $0.category == category }
    }
} 