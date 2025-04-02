import Foundation

class ProgramViewModel: ObservableObject {
    @Published var activePrograms: [Program] = []
    @Published var availablePrograms: [Program] = []
    
    init() {
        // Sample data
        activePrograms = [
            Program(title: "Speed Training", description: "Enhance your acceleration and top speed with our specialized program.", icon: "bolt.fill", duration: 12, currentWeek: 3),
            Program(title: "Strength Building", description: "Build foundational strength with progressive overload techniques.", icon: "dumbbell.fill", duration: 12, currentWeek: 3)
        ]
        
        availablePrograms = [
            Program(title: "Recovery", description: "Essential recovery protocols to maintain peak performance.", icon: "heart.fill", duration: 8, currentWeek: nil),
            Program(title: "Flexibility", description: "Improve your range of motion and prevent injuries.", icon: "figure.walk", duration: 6, currentWeek: nil),
            Program(title: "Power", description: "Explosive power development for athletic performance.", icon: "bolt.shield.fill", duration: 10, currentWeek: nil)
        ]
    }
    
    func startProgram(_ program: Program) {
        guard let index = availablePrograms.firstIndex(where: { $0.id == program.id }) else { return }
        let updatedProgram = Program(title: program.title, description: program.description, icon: program.icon, duration: program.duration, currentWeek: 1)
        availablePrograms.remove(at: index)
        activePrograms.append(updatedProgram)
    }
    
    func completeProgram(_ program: Program) {
        guard let index = activePrograms.firstIndex(where: { $0.id == program.id }) else { return }
        let updatedProgram = Program(title: program.title, description: program.description, icon: program.icon, duration: program.duration, currentWeek: nil)
        activePrograms.remove(at: index)
        availablePrograms.append(updatedProgram)
    }
} 