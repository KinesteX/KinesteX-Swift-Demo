import SwiftUI
import KinesteXAIFramework

struct HeaderView: View {
    let title: String
    let categories: [String: Int]
    var body: some View {
        VStack{
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .shadow(radius: 10)
                .padding()
            Text("Category Levels:")
                                   .font(.headline)
                                   .foregroundColor(.white)
            ForEach(categories.sorted(by: >), id: \.key) { key, value in
                                   HStack {
                                       Text("\(key):")
                                           .fontWeight(.semibold)
                                           .foregroundColor(.white)
                                       Spacer()
                                       Text("\(value)")
                                           .foregroundColor(.blue)
                                           .foregroundColor(.white)
                                   }
                                   .padding(.horizontal)
                                   .padding(.vertical, 5)
                                   .background(Color.black.opacity(0.6))
                                   .cornerRadius(8)
                               }
        }
    }
}
struct PlanDetailView: View {
    let plan: PlanModel
    @State private var expandedWeeks: [String: Bool] = [:]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Plan Image and Title
                AsyncImage(url: URL(string: plan.img_URL)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, minHeight: 200)
                        .clipped()
                        .cornerRadius(10)
                        .overlay(
                            HeaderView(title: plan.title, categories: plan.category.levels), alignment: .bottomLeading
                        )
                                
                } placeholder: {
                    ProgressView()
                        .frame(height: 200)
                }
                
                // Category Description
                Text(plan.category.description)
                    .font(.body)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                
                
                // Levels (Weeks)
                ForEach(plan.levels.keys.sorted(), id: \.self) { key in
                    if let level = plan.levels[key] {
                        VStack(alignment: .leading) {
                            // Week Header with Expand/Collapse Toggle
                            HStack {
                                Text(level.title)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                                
                                Button(action: {
                                    expandedWeeks[key]?.toggle()
                                }) {
                                    Image(systemName: expandedWeeks[key] == true ? "chevron.down" : "chevron.right")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .onAppear {
                                // Initialize expansion state
                                if expandedWeeks[key] == nil {
                                    expandedWeeks[key] = false
                                }
                            }
                            
                            // Week Description and Days (Collapsible)
                            if expandedWeeks[key] == true {
                                Text(level.description)
                                    .font(.body)
                                    .padding(.horizontal)
                                    .padding(.bottom, 5)
                                
                                ForEach(level.days.keys.sorted(), id: \.self) { dayKey in
                                    if let day = level.days[dayKey] {
                                        VStack(alignment: .leading, spacing: 8) {
                                            // Day Title and Description
                                            HStack {
                                                Text(day.title)
                                                    .font(.headline)
                                                    .foregroundColor(day.title == "Rest today" ? .yellow : .white)
                                                Spacer()
                                            }
                                            .padding(.horizontal)
                                            
                                            Text(day.description)
                                                .font(.body)
                                                .foregroundColor(.secondary)
                                                .padding(.horizontal)
                                            
                                            // Workouts for the Day
                                            if let workouts = day.workouts {
                                                ScrollView(.horizontal, showsIndicators: false) {
                                                    VStack(spacing: 15) {
                                                        ForEach(workouts, id: \.id) { workout in
                                                                
                                                            Text("ID: \(workout.id)")
                                                                .font(.headline)
                                                             
                                                            
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        .padding()
                                        .background(Color.gray.opacity(0.5))
                                        .cornerRadius(10)
                                        .shadow(radius: 2)
                                        .padding(.horizontal)
                                        .padding(.vertical, 5)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Plan Details")
    }
}
