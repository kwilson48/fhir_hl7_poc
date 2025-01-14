
import SwiftUI

@main
struct FHIRHL7App: App {
    @State private var container: DependencyContainerProtocol?
    
    var body: some Scene {
        WindowGroup {
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
