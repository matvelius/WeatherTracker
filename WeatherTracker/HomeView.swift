//
//  ContentView.swift
//  WeatherTracker
//
//  Created by Matvey Kostukovsky on 12/11/24.
//

import SwiftUI

struct HomeView: View {
    @State var viewModel = HomeViewModel()
    
    @State private var showingAlert = false
    @State private var apiKey = ""
    
    @State private var searchIsActive = false
        
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView()
                // location selected, weather available, and not currently searching
                } else if let selectedLocation = viewModel.selectedLocation,
                   let weather = viewModel.currentWeather,
                   !viewModel.searchIsActive,
                   viewModel.searchQuery.isEmpty {
                    locationView(with: selectedLocation.name, and: weather)
                // no location selected, not currently searching
                } else if viewModel.searchQuery.isEmpty && !viewModel.searchIsActive {
                    noLocationEmptyView()
                // searching, no results
                } else if viewModel.searchResults.isEmpty && viewModel.searchQuery.count >= 3 {
                    noResultsEmptyView()
                // searching, results found
                } else {
                    searchResultsView()
                }
            }
        }
        .padding()
        .searchable(text: $viewModel.searchQuery,
                    isPresented: $viewModel.searchIsActive,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: Text("Search Location"))
        .task {
            await viewModel.checkCacheAndLoadWeather()
        }
        .alert("WeatherAPI.com requires a valid API key", isPresented: $viewModel.apiKeyMissing) {
            TextField("Please enter your API key", text: $apiKey)
            Button {
                viewModel.storeAPIKey(apiKey)
            } label: {
                Text("Submit")
            }
            .disabled(apiKey.isEmpty)
        }
    }
    
    @ViewBuilder
    func locationView(with locationName: String, and weather: Weather) -> some View {
        VStack(alignment: .center) {
            AsyncImage(url: URL(string: weather.condition.icon)) { result in
                result.image?
                    .resizable()
                    .scaledToFill()
            }
            .frame(width: 123, height: 123)
            .padding()
            
            Text(locationName)
                .font(.title)
                .fontWeight(.heavy)
                .multilineTextAlignment(.center)
                .padding()
            
            Text(intStringFrom(float: weather.tempC) + "°")
                .font(.system(size: 70))
                .fontWeight(.bold)
                .padding()
            
            HStack {
                VStack(spacing: 7) {
                    Text("Humidity")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                    Text(weather.humidity.description + "%")
                        .font(.system(size: 15))
                        .foregroundStyle(.primary)
                }
                .padding(.horizontal, 14)
                
                VStack(spacing: 7) {
                    Text("UV")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                    Text(intStringFrom(float: weather.uv))
                        .font(.system(size: 15))
                        .foregroundStyle(.primary)
                }
                .padding(.horizontal, 14)
                
                VStack(spacing: 7) {
                    Text("Feels Like")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                    Text(intStringFrom(float: weather.feelslikeC) + "°")
                        .font(.system(size: 15))
                        .foregroundStyle(.primary)
                }
                .padding(.horizontal, 14)
            }
            .fontDesign(.rounded)
            .fontWidth(.expanded)
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 14).fill(Color("background")))
        }
        Spacer()
    }
    
    @ViewBuilder
    func searchResultsView() -> some View {
        List {
            ForEach(viewModel.searchResults, id: \.id) { result in
                Button {
                    viewModel.handleSelection(result)
                } label: {
                    Text(result.name + " (\(result.region), \(result.country))")
                        .lineLimit(1)
                }
            }
        }
        .listStyle(.plain)
    }
    
    @ViewBuilder
    func noLocationEmptyView() -> some View {
        VStack {
            Spacer()
            Text("No City Selected")
                .font(.title)
            Text("Please Search For A City")
            Spacer()
        }
    }
    
    @ViewBuilder
    func noResultsEmptyView() -> some View {
        VStack {
            Spacer()
            Text("No locations found - please try a different search query.")
            Spacer()
        }
    }
    
    private func intStringFrom(float: Float) -> String {
        Int(float).description
    }
}

#Preview {
    HomeView()
}
