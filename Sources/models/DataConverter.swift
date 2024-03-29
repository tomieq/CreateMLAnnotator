//
//  DataConverter.swift
//
//
//  Created by Tomasz on 29/03/2024.
//

import Foundation

class DataConverter {
    func uiToCreateML(left: Int, top: Int, width: Int, height: Int) -> Coordinate {
        Coordinate(x: left + width / 2,
                   y: top + height / 2,
                   width: width,
                   height: height)
    }
    
    func createMLToUI(coordinate: Coordinate) -> (left: Int, top: Int, width: Int, height: Int) {
        (left: coordinate.x - coordinate.width / 2,
         top: coordinate.y - coordinate.height / 2,
         width: coordinate.width,
         height: coordinate.height)
    }
}
