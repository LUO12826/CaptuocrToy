//
//  Recognizer.swift
//  Captuocr
//
//  Created by Gragrance on 2017/12/1.
//  Copyright © 2017年 Gragrance. All rights reserved.
//

import Foundation

protocol Recognizer: class {
    func recognize(data: Data, progress: ((Double) -> Void)?) throws -> String
}
