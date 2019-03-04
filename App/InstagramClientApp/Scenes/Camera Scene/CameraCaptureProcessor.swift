//
//  CameraCaptureProcessor.swift
//  InstagramClientApp
//
//  Created by 심승민 on 23/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import AVFoundation
import InstagramEngine

final class CameraCaptureProcessor: NSObject {
    private var photoOutput: AVCapturePhotoOutput!
    private var settings: AVCapturePhotoSettings!
    var finishProcessingPhotoCompletion: ((Result<Data, CameraViewController.Error>) -> Void)?
    
    convenience init(photoOutput: AVCapturePhotoOutput, settings: AVCapturePhotoSettings) {
        self.init()
        self.photoOutput = photoOutput
        self.settings = settings
    }
    
    func capturePhoto() {
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraCaptureProcessor: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            finishProcessingPhotoCompletion?(.failure(.photoProcessingError))
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(), imageData.count > 0 else {
            finishProcessingPhotoCompletion?(.failure(.photoDataNotExist))
            return
        }
        
        finishProcessingPhotoCompletion?(.success(imageData))
    }
}
