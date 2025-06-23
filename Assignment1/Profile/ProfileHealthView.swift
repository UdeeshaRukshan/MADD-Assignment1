import SwiftUI
import HealthKit

struct ProfileHealthView: View {
    @StateObject private var healthVM = HealthDashboardViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "141E30"),
                        Color(hex: "243B55")
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    Text("My Health Dashboard")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 30)
                    
                    VStack(spacing: 20) {
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 32))
                            VStack(alignment: .leading) {
                                Text("Heart Rate")
                                    .foregroundColor(.white)
                                if let bpm = healthVM.heartRate {
                                    Text("\(Int(bpm)) BPM")
                                        .font(.title)
                                        .foregroundColor(.white)
                                } else {
                                    Text("Not available")
                                        .foregroundColor(.gray)
                                }
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color(hex: "1A2133"))
                        .cornerRadius(12)
                        
                        HStack {
                            Image(systemName: "figure.walk")
                                .foregroundColor(.green)
                                .font(.system(size: 32))
                            VStack(alignment: .leading) {
                                Text("Steps Today")
                                    .foregroundColor(.white)
                                if let steps = healthVM.steps {
                                    Text("\(steps)")
                                        .font(.title)
                                        .foregroundColor(.white)
                                } else {
                                    Text("Not available")
                                        .foregroundColor(.gray)
                                }
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color(hex: "1A2133"))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    Button {
                        healthVM.refresh()
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 30)
                            .background(Color(hex: "64B5F6"))
                            .cornerRadius(10)
                    }
                    .padding(.top, 10)
                    
                    Spacer()
                }
            }
            .navigationTitle("Health")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                healthVM.refresh()
            }
        }
    }
}

class HealthDashboardViewModel: ObservableObject {
    private let healthStore = HKHealthStore()
    @Published var heartRate: Double?
    @Published var steps: Int?
    
    func refresh() {
        requestAuthorizationIfNeeded {
            self.fetchLatestHeartRate()
            self.fetchTodaySteps()
        }
    }
    
    private func requestAuthorizationIfNeeded(completion: @escaping () -> Void) {
        #if targetEnvironment(simulator)
        // Skip HealthKit on simulator/preview
        completion()
        #else
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let types: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .stepCount)!
        ]
        healthStore.requestAuthorization(toShare: [], read: types) { success, _ in
            DispatchQueue.main.async {
                completion()
            }
        }
        #endif
    }
    
    private func fetchLatestHeartRate() {
        let type = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sort]) { [weak self] _, samples, _ in
            guard let sample = samples?.first as? HKQuantitySample else { return }
            let bpm = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            DispatchQueue.main.async {
                self?.heartRate = bpm
            }
        }
        healthStore.execute(query)
    }
    
    private func fetchTodaySteps() {
        let type = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, _ in
            let steps = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
            DispatchQueue.main.async {
                self?.steps = Int(steps)
            }
        }
        healthStore.execute(query)
    }
}

#if DEBUG
struct ProfileHealthView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileHealthView()
            .environment(\.colorScheme, .dark)
    }
}
#endif
