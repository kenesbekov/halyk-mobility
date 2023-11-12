//
//  MainView.swift
//  Halyk Mobility
//
//  Created by Adam Kenesbekov on 11.11.2023.
//

import SwiftUI

struct MainView: View {
    @State private var isSheetExpanded = true
    @State private var searchText = ""

    var body: some View {
        MapView()
            .edgesIgnoringSafeArea(.all)
            .sheet(isPresented: $isSheetExpanded) {
                MainViewBottomView(
                    isSheetExpanded: $isSheetExpanded,
                    searchText: $searchText
                )
                .presentationDetents([.medium, .large])
            }
    }
}


#Preview {
    MainView()
}
