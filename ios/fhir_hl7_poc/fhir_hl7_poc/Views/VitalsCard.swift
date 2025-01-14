import SwiftUI

struct VitalsCard: View {
    let observation: LocalObservationData?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Vitals")
                .font(AppTypography.sectionTitle)
                .foregroundColor(AppColors.darkBlue)
            
            if let observation = observation {
                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Type")
                            .font(AppTypography.labelText)
                            .foregroundColor(AppColors.darkBlue)
                        Text(observation.codeText)
                            .font(AppTypography.bodyText)
                            .foregroundColor(.secondary)
                    }
                    
                    if let value = observation.value {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Value")
                                .font(AppTypography.labelText)
                                .foregroundColor(AppColors.darkBlue)
                            Text("\(value) bpm")
                                .font(AppTypography.bodyText)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let date = observation.effectiveDate {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Measured On")
                                .font(AppTypography.labelText)
                                .foregroundColor(AppColors.darkBlue)
                            Text(DateFormatter.formatDateTime(date))
                                .font(AppTypography.bodyText)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            } else {
                Text("No vitals data available")
                    .font(AppTypography.bodyText)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
} 