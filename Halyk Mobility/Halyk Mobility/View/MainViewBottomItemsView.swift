//
//  MainViewBottomItemsView.swift
//  Halyk Mobility
//
//  Created by Adam Kenesbekov on 11.11.2023.
//

import SwiftUI

struct MainViewBottomItemsView: View {
    @Binding var searchText: String

    var onSearchAction: () -> Void
    var onButtonAction: () -> Void

    var body: some View {
        VStack {
            HStack {
                SearchBarView(
                    searchText: $searchText,
                    onSearchAction: onSearchAction
                )

                LocateMeView(didTap: {})
            }

            ScrollView(.horizontal) {
                HStack {
                    BottomItemActionView(didTap: {}, icon: "bookmark", name: "Избранное")
                    BottomItemActionView(didTap: {}, icon: "bookmark", name: "Избранное")
                    BottomItemActionView(didTap: {}, icon: "bookmark", name: "Избранное")
                }
            }
            .scrollIndicators(.hidden)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct SearchBarView: View {
    @Binding var searchText: String
    var onSearchAction: () -> Void

    var body: some View {
        HStack {
            ZStack {
                Color.gray.opacity(0.1)
                    .cornerRadius(12)

                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)

                    TextField("Куда едем?", text: $searchText)
                }
                .padding()
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct LocateMeView: View {
    let didTap: () -> Void

    var body: some View {
        Button(action: didTap) {
            Image(systemName: "location")
                .frame(maxWidth: .infinity)
                .background(
                    Color.gray.opacity(0.1)
                        .cornerRadius(12)
                )
        }
    }
}

struct BottomItemActionView: View {
    let didTap: () -> Void

    let icon: String
    let name: String

    var body: some View {
        Button(action: didTap) {
            Label(name, systemImage: icon)
                .padding()
                .foregroundColor(.secondary)
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}
