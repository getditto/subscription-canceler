//
//  ContentView.swift
//  SubscriptionCanceler
//
//  Created by Maximilian Alexander on 2/16/23.
//

import SwiftUI
import DittoSwift
import Fakery

struct ContentView: View {

    class ViewModel: ObservableObject {

        @Published var cars: [Car] = []
        @Published var subscribedToBrand: Brand?

        private var liveQuery: DittoLiveQuery?

        private var activeSubscription: DittoSubscription?

        init() {
            liveQuery = DittoManager.shared.ditto
                .store["cars"]
                .findAll()
                .observeLocal(eventHandler: { [weak self] docs, e in
                    let cars = docs.map({ Car(document: $0) })
                    self?.cars = cars
                })
        }

        func createCarsByBrand(brand: Brand) {
            let faker = Faker()
            DittoManager.shared.ditto.store.write { trx in
                for _ in 0..<100 {
                    let _  = try? trx["cars"].upsert(Car(id: UUID().uuidString, brand: brand.rawValue, color: faker.commerce.color(), mileage: faker.number.randomInt()).asDittoDocumentDictionary)
                }
            }
        }

        func subscribeToBrandAndEvictOthers(brand: Brand) {
            // cancel the active subscription
            activeSubscription?.cancel()
            activeSubscription = nil

            // evict all the other brands
            DittoManager.shared.ditto.store["cars"].find("brand != $args.brand", args: ["brand": brand.rawValue]).evict()

            // subscribe to the new brand
            subscribedToBrand = brand
            activeSubscription = DittoManager.shared.ditto.store["cars"].find("brand == $args.brand", args: ["brand": brand.rawValue]).subscribe()
        }

    }

    @StateObject var viewModel = ViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(Brand.allCases, id: \.self) { brand in
                    HStack {
                        Image(systemName: brand == viewModel.subscribedToBrand ? "circle.fill" : "circle")
                            .renderingMode(.template)
                            .resizable()
                            .tint(.blue)
                            .frame(width: 25, height: 25)

                        VStack(alignment: .leading) {
                            Text(brand.rawValue)
                                .font(.title)
                                .bold()
                            Text("Documents \(viewModel.cars.filter({ $0.brand == brand.rawValue }).count)")
                            HStack {
                                Button("Create cars") {
                                    viewModel.createCarsByBrand(brand: brand)
                                }
                                .tint(.green)
                                .buttonStyle(.bordered)
                                Spacer()
                                Button("Subscribe and Evict Others") {
                                    viewModel.subscribeToBrandAndEvictOthers(brand: brand)
                                }
                                .foregroundColor(.red)
                                .buttonStyle(.bordered)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Brands")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
