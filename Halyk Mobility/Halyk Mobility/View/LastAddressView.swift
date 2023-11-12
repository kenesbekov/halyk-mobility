//
//  LastAddressView.swift
//  Halyk Mobility
//
//  Created by Adam Kenesbekov on 11.11.2023.
//

import SwiftUI

struct LastAddress {
    let name: String
}

struct LastAddressView: View {
    let lastAddress: LastAddress

    var body: some View {
        VStack {
            ZStack {
                Image(systemName: "timelapse")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 42)

                Circle()
                    .stroke(Color.green, style: StrokeStyle())
                    .foregroundColor(.white)
            }

            Text(lastAddress.name)
        }
    }
}

#Preview {
    LastAddressView(lastAddress: .init(name: "Абая 134"))
}
