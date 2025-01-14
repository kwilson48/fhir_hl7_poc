
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: PatientViewModel
    private let container: DependencyContainerProtocol
    
    init(container: DependencyContainerProtocol) {
        let tempViewModel = PatientViewModel()
        _viewModel = StateObject(wrappedValue: tempViewModel)
        self.container = container
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding(.top, 40)
                    } else if let error = viewModel.error {
                        ErrorView(error: error)
                    } else {
                        Text("HL7 POC")
                            .font(AppTypography.headerTitle)
                            .foregroundColor(AppColors.darkBlue)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                        
                        VStack(spacing: 16) {
                            PatientInfoCard(viewModel: viewModel)
                            VitalsCard(observation: viewModel.heartRate)
                            AppointmentCard(appointment: viewModel.appointment)
                            ContactInfoCard(viewModel: viewModel)
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical)
                .background(AppColors.lightBlue)
            }
            .background(AppColors.lightBlue)
        }
        .tint(AppColors.darkBlue)
        .onAppear {
            Task {
                await viewModel.configure(
                    repository: container.healthDataRepository,
                    logger: container.logger
                )
                await viewModel.fetchHealthData()
            }
        }
    }
}

struct PatientInfoCard: View {
    @ObservedObject var viewModel: PatientViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Patient Information")
                .font(AppTypography.sectionTitle)
                .foregroundColor(AppColors.darkBlue)
            
            VStack(alignment: .leading, spacing: 8) {
                LabeledContent("Name", value: viewModel.getFormattedName())
                    .labeledContentStyle(CustomLabeledContentStyle())
                if let gender = viewModel.patient?.gender {
                    LabeledContent("Gender", value: gender.capitalized)
                        .labeledContentStyle(CustomLabeledContentStyle())
                }
                if let birthDate = viewModel.patient?.birthDate {
                    LabeledContent("Birth Date", value: DateFormatter.formatDate(birthDate))
                        .labeledContentStyle(CustomLabeledContentStyle())
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct ContactInfoCard: View {
    @ObservedObject var viewModel: PatientViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Contact Information")
                .font(AppTypography.sectionTitle)
                .foregroundColor(AppColors.darkBlue)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(viewModel.getPhoneNumbers(), id: \.self) { phone in
                    LabeledContent("Phone", value: phone)
                        .labeledContentStyle(CustomLabeledContentStyle())
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct ErrorView: View {
    let error: Error
    
    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
            Text("Error")
                .font(.headline)
            Text(error.localizedDescription)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AsyncContentView()
    }
    
    private struct AsyncContentView: View {
        @State private var container: DependencyContainer?
        
        var body: some View {
            Group {
                if let container = container {
                    ContentView(container: container)
                } else {
                    ProgressView()
                        .task {
                            container = await DependencyContainer()
                        }
                }
            }
        }
    }
}
