//
//  Utilities.swift
//  Photagrapher
//
//  Created by Richie Flores on 8/1/22.
//

import Foundation

class Utilities {
  static func getApplicationDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
  }
}
