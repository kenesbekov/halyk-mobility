//
//  MainViewBottomView.swift
//  Halyk Mobility
//
//  Created by Adam Kenesbekov on 11.11.2023.
//

import SwiftUI

struct MainViewBottomView: View {
    @Binding var isSheetExpanded: Bool
    @Binding var searchText: String

    private var lastAddressView: some View {
        LastAddressView(lastAddress: .init(name: "Абая 134"))
    }

    var body: some View {
        VStack {
            MainViewBottomItemsView(searchText: $searchText, onSearchAction: {}, onButtonAction: {})

            HStack {
                lastAddressView
                lastAddressView
                lastAddressView
                lastAddressView
            }
        }
        .interactiveDismissDisabled()
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

//#Preview {
//    MainViewBottomView(isSheetExpanded: $true)
//}
