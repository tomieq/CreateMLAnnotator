//
//  DataConverter.swift
//
//
//  Created by Tomasz on 29/03/2024.
//

import Foundation

class DataConverter {
    func uiToCreateML(frame: Frame) -> Coordinate {
        Coordinate(x: frame.left + frame.width / 2,
                   y: frame.top + frame.height / 2,
                   width: frame.width,
                   height: frame.height)
    }
    
    func createMLToUI(coordinate: Coordinate) -> Frame {
        Frame(left: coordinate.x - coordinate.width / 2,
              top: coordinate.y - coordinate.height / 2,
              width: coordinate.width,
              height: coordinate.height)
    }
}
