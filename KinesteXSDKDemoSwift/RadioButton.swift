//
//  RadioButton.swift
//  KinesteXSDK
//
//  Created by Vladimir Shetnikov on 4/8/24.
//

import SwiftUI

struct RadioButton: View {
    let title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
             
                Text(title)
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .foregroundColor(isSelected ? .green : .gray) // Change the color to indicate selection
            }
            .padding(.vertical, 10)
            
         
        }
    }
}
