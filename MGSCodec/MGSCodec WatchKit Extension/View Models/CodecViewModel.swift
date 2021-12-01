//
//  CodecViewModel.swift
//  MGSCodec
//
//  Created by Matthew Martindale on 12/1/21.
//

import Foundation

class CodecViewModel {
    var crownAccumulator = 0.0
    var crownValue = Box(value: 140.85)
    let decimalFormatter: NumberFormatter = {
       let decimalFormatter = NumberFormatter()
        decimalFormatter.numberStyle = .decimal
        decimalFormatter.minimumFractionDigits = 2
        decimalFormatter.maximumFractionDigits = 2
        return decimalFormatter
    }()
    
    func handleCrownDidRotate() {
        if crownValue.value < 140.00 {
            crownValue.value = 142.99
        }
        if crownValue.value > 142.99 {
            crownValue.value = 140.00
        }
        
        if crownAccumulator > 0.06 {
            crownValue.value += 0.01
            crownAccumulator = 0.0
        } else if crownAccumulator < -0.06 {
            crownValue.value -= 0.01
            crownAccumulator = 0.0
        }
    }
}
