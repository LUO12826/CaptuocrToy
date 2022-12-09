//
//  macOSRecognizer.swift
//  Captuocr
//
//  Created by 骆荟州 on 2022/12/8.
//  Copyright © 2022 Gragrance. All rights reserved.
//

import Foundation
import Vision
import AppKit

class macOSRecognizer: Recognizer {
    
    func recognize(data: Data, progress: ((Double) -> Void)? = nil) throws -> String {
        progress?(0)
        
        
        guard let img = NSImage(data: data) else {
            throw NSError(domain: "Bad image data.", code: 0, userInfo: nil)
        }
        guard let imgRef = img.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw NSError(domain: "Error: failed to convert NSImage to CGImage.", code: 0, userInfo: nil)
        }
        
        let semaphore = DispatchSemaphore(value: 1)
        
        var result: String?

        let request = VNRecognizeTextRequest { (request, error) in
            let observations = request.results as? [VNRecognizedTextObservation] ?? []
            let obs: [String] = observations.map { $0.topCandidates(1).first?.string ?? ""}
            
            result = self.joinString(array: obs)
            
            semaphore.signal()
        }
        request.recognitionLevel = VNRequestTextRecognitionLevel.accurate // or .fast
        request.usesLanguageCorrection = true
        request.revision = VNRecognizeTextRequestRevision2
        request.recognitionLanguages = ["zh-Hans", "zh-Hant", "en-US"]
        request.usesLanguageCorrection = true
        
//        print(try VNRecognizeTextRequest.supportedRecognitionLanguages(for: .accurate, revision: 2))
        // request.customWords = ["der", "Der", "Name"]

        try? VNImageRequestHandler(cgImage: imgRef, options: [:]).perform([request])
        semaphore.wait()
        
        return result ?? ""
    }
    
    func joinString(array: [String]) -> String {
        return array.joined(separator: "\n")
    }
}
