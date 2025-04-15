import SwiftUI

public struct ProgramCard: View {
    let program: SavedProgram
    
    public init(program: SavedProgram) {
        self.program = program
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(program.category.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.2))
                    .foregroundColor(.red)
                    .cornerRadius(8)
                
                Spacer()
                
                Text("\(program.weeks.count) weeks")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text(program.name)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(program.description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(2)
            
            Text(program.dateCreated, style: .date)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
} 