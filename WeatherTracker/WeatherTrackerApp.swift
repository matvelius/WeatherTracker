//
//  WeatherTrackerApp.swift
//  WeatherTracker
//
//  Created by Matvey Kostukovsky on 12/11/24.
//

import SwiftUI

@main
struct WeatherTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContainerView()
        }
    }
}

struct ContainerView: View {
    @State private var showSplashScreen = true

    var body: some View {
        ZStack {
            if showSplashScreen {
                LaunchScreenView()
                    .transition(.opacity)
            } else {
                HomeView()
                    .transition(.opacity)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeIn(duration: 0.5)) {
                    showSplashScreen = false
                }
            }
        }
    }
}

struct LaunchScreenView: View {
    var body: some View {
        ZStack {
            Image("SplashScreen")
                .resizable()
                .ignoresSafeArea()
                .aspectRatio(contentMode: .fill)
            VStack {
                Spacer()
                Text("Weather Tracker")
                    .font(.largeTitle)
                    .fontDesign(.rounded)
                    .foregroundStyle(Color.black)
                    .padding(.top, 250)
                    .opacity(0.4)
                Spacer()
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
