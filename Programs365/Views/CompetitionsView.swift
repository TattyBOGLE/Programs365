import SwiftUI

struct CompetitionCard: View {
    let title: String
    let date: String
    let location: String
    let isUpcoming: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(isUpcoming ? Color.blue : Color.gray)
                    .frame(width: 10, height: 10)
                Text(title)
                    .font(.headline)
            }
            
            Text(date)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text(location)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            if isUpcoming {
                Button(action: {}) {
                    Text("Register")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}

struct CompetitionsView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Upcoming")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    VStack(spacing: 16) {
                        CompetitionCard(
                            title: "Speed Championship 2024",
                            date: "June 15, 2024",
                            location: "Sydney Olympic Park",
                            isUpcoming: true
                        )
                        
                        CompetitionCard(
                            title: "National Athletics Meet",
                            date: "July 22, 2024",
                            location: "Melbourne Sports Hub",
                            isUpcoming: true
                        )
                    }
                    .padding(.horizontal)
                    
                    Text("Past")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    VStack(spacing: 16) {
                        CompetitionCard(
                            title: "Regional Sprint Finals",
                            date: "March 10, 2024",
                            location: "Brisbane Stadium",
                            isUpcoming: false
                        )
                        
                        CompetitionCard(
                            title: "Summer Athletics Series",
                            date: "February 28, 2024",
                            location: "Gold Coast Track",
                            isUpcoming: false
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Competitions")
            .toolbar {
                Button(action: {}) {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

#Preview {
    CompetitionsView()
} 