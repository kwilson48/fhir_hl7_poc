import SwiftUI

struct AppointmentCard: View {
    let appointment: LocalAppointment?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Appointment")
                .font(AppTypography.sectionTitle)
                .foregroundColor(AppColors.darkBlue)
            
            if let appointment = appointment {
                VStack(alignment: .leading, spacing: 8) {
                    if let start = appointment.start {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Date & Time")
                                .font(AppTypography.labelText)
                                .foregroundColor(AppColors.darkBlue)
                            Text(DateFormatter.formatDateTime(start))
                                .font(AppTypography.bodyText)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let provider = appointment.participants.first(where: { participant in
                        participant.type.contains { type in
                            type.coding.contains { coding in
                                coding.code == "ATND"
                            }
                        }
                    }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Provider")
                                .font(AppTypography.labelText)
                                .foregroundColor(AppColors.darkBlue)
                            Text(provider.actor.display ?? "Unknown Provider")
                                .font(AppTypography.bodyText)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let location = appointment.participants.first(where: { participant in
                        participant.actor.reference?.starts(with: "Location/") == true
                    }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Location")
                                .font(AppTypography.labelText)
                                .foregroundColor(AppColors.darkBlue)
                            Text(location.actor.display ?? "Unknown Location")
                                .font(AppTypography.bodyText)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let description = appointment.description {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Description")
                                .font(AppTypography.labelText)
                                .foregroundColor(AppColors.darkBlue)
                            Text(description)
                                .font(AppTypography.bodyText)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if !appointment.patientInstructions.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Instructions")
                                .font(AppTypography.labelText)
                                .foregroundColor(AppColors.darkBlue)
                            ForEach(appointment.patientInstructions, id: \.self) { instruction in
                                Text("• \(instruction)")
                                    .font(AppTypography.bodyText)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            } else {
                Text("No appointment scheduled")
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
