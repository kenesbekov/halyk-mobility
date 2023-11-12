//
//  TabBarView.swift
//  Halyk Mobility
//
//  Created by Adam Kenesbekov on 11.11.2023.
//

import SwiftUI

struct TabBarView: View {
    var body: some View {
        TabView {
            CarRecognitionView()
                .tabItem {
                    Image(systemName: "car.2.fill")
                    Text("Car Recognition")
                }
            ChatBotView()
                .tabItem {
                    Image(systemName: "arrow.up.backward.bottomtrailing.rectangle.fill")
                    Text("ChatBot")
                }
        }
    }
}

#Preview {
    TabBarView()
}
