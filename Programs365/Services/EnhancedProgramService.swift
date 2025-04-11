import Foundation
import SwiftUI

public class EnhancedProgramService: ObservableObject {
    private let chatGPTService: ChatGPTService
    private var cache: [String: String] = [:]
    @Published public private(set) var isLoading = false
    @Published public private(set) var error: String?
    
    public init(chatGPTService: ChatGPTService) {
        self.chatGPTService = chatGPTService
    }
    
    // MARK: - Program Generation
    
    public func generateProgram(parameters: EnhancedProgramParameters, week: Int) async throws -> String {
        let cacheKey = generateCacheKey(parameters: parameters, week: week)
        
        if let cachedProgram = cache[cacheKey] {
            return cachedProgram
        }
        
        let prompt = generatePrompt(parameters: parameters, week: week)
        let program = try await chatGPTService.generateResponse(prompt: prompt)
        
        cache[cacheKey] = program
        return program
    }
    
    // MARK: - Helper Methods
    
    private func generateCacheKey(parameters: EnhancedProgramParameters, week: Int) -> String {
        return """
        \(parameters.ageGroup.rawValue)_\(parameters.event.rawValue)_\(parameters.term.rawValue)_\
        \(parameters.period.rawValue)_\(parameters.gender.rawValue)_\(parameters.periodizationModel.rawValue)_\
        \(parameters.loadManagement.rawValue)_\(week)
        """
    }
    
    private func generatePrompt(parameters: EnhancedProgramParameters, week: Int) -> String {
        var prompt = """
        Generate a detailed training program with the following parameters:
        
        Athlete Profile:
        - Age Group: \(parameters.ageGroup.rawValue)
        - Event: \(parameters.event.rawValue)
        - Gender: \(parameters.gender.rawValue)
        - Training History: \(parameters.trainingHistory) years
        
        Training Context:
        - Term: \(parameters.term.rawValue)
        - Period: \(parameters.period.rawValue)
        - Week: \(week)
        - Periodization Model: \(parameters.periodizationModel.rawValue)
        - Load Management: \(parameters.loadManagement.rawValue)
        
        Environmental Factors:
        - Training Environment: \(parameters.environment.rawValue)
        - Weather Conditions: \(parameters.weather.rawValue)
        
        Format the program as follows:
        1. Use MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY as day headers in all caps
        2. List the workout details under each day
        3. Include rest and recovery recommendations
        4. Add technical focus points
        5. Specify key performance indicators
        """
        
        if !parameters.facilityLimitations.isEmpty {
            prompt += "\nFacility Limitations:"
            parameters.facilityLimitations.forEach { limitation in
                prompt += "\n- \(limitation.rawValue)"
            }
        }
        
        if !parameters.previousInjuries.isEmpty {
            prompt += "\nPrevious Injuries:"
            parameters.previousInjuries.forEach { injury in
                prompt += "\n- \(injury)"
            }
        }
        
        if let menstrualPhase = parameters.menstrualPhase {
            prompt += "\nFemale Athlete Considerations:"
            prompt += "\n- Menstrual Phase: \(menstrualPhase.rawValue)"
        }
        
        // Add event-specific considerations
        prompt += generateEventSpecificPrompt(event: parameters.event)
        
        // Add periodization-specific guidelines
        prompt += generatePeriodizationPrompt(model: parameters.periodizationModel, week: week)
        
        // Add load management guidelines
        prompt += generateLoadManagementPrompt(type: parameters.loadManagement)
        
        return prompt
    }
    
    private func generateEventSpecificPrompt(event: TrackEvent) -> String {
        var prompt = "\n\nEvent-Specific Guidelines:"
        
        switch event.category {
        case "Sprints":
            prompt += """
            \n- Focus on acceleration and maximum velocity mechanics
            \n- Include CNS-intensive work early in the week
            \n- Incorporate technical drills for sprint mechanics
            \n- Add plyometric exercises for power development
            \n- Include specific hamstring injury prevention work
            """
            
        case "Middle Distance", "Long Distance":
            prompt += """
            \n- Balance aerobic and anaerobic development
            \n- Include threshold and VO2max sessions
            \n- Focus on running economy
            \n- Add strength endurance work
            \n- Include specific calf and achilles injury prevention
            """
            
        case "Hurdles":
            prompt += """
            \n- Focus on hurdle technique and rhythm
            \n- Include lead leg and trail leg drills
            \n- Add mobility work for hip flexors and hamstrings
            \n- Include sprint mechanics between hurdles
            \n- Focus on specific hurdle injury prevention
            """
            
        case "Jumps":
            prompt += """
            \n- Focus on approach run consistency
            \n- Include specific jumping mechanics
            \n- Add plyometric progression
            \n- Include ankle and knee stability work
            \n- Focus on landing mechanics and injury prevention
            """
            
        case "Throws":
            prompt += """
            \n- Focus on throwing technique
            \n- Include rotational power development
            \n- Add core and upper body strength work
            \n- Include shoulder and trunk stability
            \n- Focus on specific throwing injury prevention
            """
            
        default:
            prompt += "\n- Include event-specific technical work"
        }
        
        return prompt
    }
    
    private func generatePeriodizationPrompt(model: PeriodizationModel, week: Int) -> String {
        var prompt = "\n\nPeriodization Guidelines:"
        
        switch model {
        case .linear:
            prompt += """
            \n- Progressive increase in intensity
            \n- Maintain consistent volume
            \n- Focus on sequential adaptation
            """
            
        case .undulating:
            prompt += """
            \n- Vary daily training demands
            \n- Alternate between high and low intensity
            \n- Include recovery microcycles
            """
            
        case .block:
            prompt += """
            \n- Concentrated load of specific abilities
            \n- Focus on primary training target
            \n- Include restoration periods
            """
            
        case .wave:
            prompt += """
            \n- Wave-like progression of load
            \n- Include regular deload periods
            \n- Balance intensity and volume
            """
        }
        
        return prompt
    }
    
    private func generateLoadManagementPrompt(type: LoadManagementType) -> String {
        var prompt = "\n\nLoad Management Guidelines:"
        
        switch type {
        case .standard:
            prompt += """
            \n- Regular progression of training load
            \n- Weekly recovery sessions
            \n- Balance work-to-rest ratio
            """
            
        case .conservative:
            prompt += """
            \n- Gradual progression of load
            \n- Extra recovery sessions
            \n- Reduced high-intensity volume
            """
            
        case .aggressive:
            prompt += """
            \n- Rapid progression of load
            \n- Strategic recovery placement
            \n- Higher training density
            """
            
        case .recovery:
            prompt += """
            \n- Reduced training volume
            \n- Focus on technique
            \n- Emphasis on recovery
            """
        }
        
        return prompt
    }
} 