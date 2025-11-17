//
//  ImageExtension.swift
//  CountryLookup
//
//  Created by Amr El Shazly on 14/11/2025.
//

import Foundation
import SwiftUI

extension Image {
    func resizedToFill(width: CGFloat, height: CGFloat) -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: width, height: height)
    }
}
