//
//  CameraViewController.swift
//  InstagramClientApp
//
//  Created by 심승민 on 22/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    // MARK: UI Properties
    
    // MARK: Private Properties
    private var router: CameraRouter.Routes?
    private let sessionQueue = DispatchQueue(label: "com.instagramApp.cameraSessionQueue", qos: .userInitiated)
    private let captureSession: AVCaptureSession = AVCaptureSession()
    
    // MARK: Init
    convenience init(router: CameraRouter.Routes) {
        self.init()
        self.router = router
    }
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sessionQueue.async {
            self.checkDeviceAuthorization {
                self.displayAlertWithOpenSettings($0)
            }
            self.configureSession {
                self.displayAlertAndClosePage($0)
            }
        }
        
        setupPreviewLayer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sessionQueue.async {
            self.captureSession.startRunning()
        }
    }
    
    // MARK: Actions
    @IBAction func captureButtonDidTap(_ sender: UIButton) {
        
    }
    
    @IBAction func backButtonDidTap(_ sender: UIButton) {
        router?.openHomeFeedPage()
    }
}

extension CameraViewController {
    // MARK: Private Methods
    private func configureSession(_ completion: @escaping (Error) -> Void) {
        captureSession.beginConfiguration()
        
        guard let device = AVCaptureDevice.default(for: .video) else {
            completion(.deviceUnavailable)
            captureSession.commitConfiguration()
            return
        }
        
        guard let input = try? AVCaptureDeviceInput(device: device) else {
            completion(.constructDeviceInputError)
            captureSession.commitConfiguration()
            return
        }
        guard captureSession.canAddInput(input) else {
            completion(.addDeviceInputError)
            captureSession.commitConfiguration()
            return
        }
        captureSession.addInput(input)
        
        let output = AVCapturePhotoOutput()
        guard captureSession.canAddOutput(output) else {
            completion(.addDeviceOutputError)
            captureSession.commitConfiguration()
            return
        }
        captureSession.addOutput(output)
        
        captureSession.commitConfiguration()
    }
    
    private func checkDeviceAuthorization(_ completion: @escaping (Error) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: return
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video) { granted in
                granted ? nil : completion(.notAuthorized)
                self.sessionQueue.resume()
            }
        default: completion(.notAuthorized)
        }
    }
    
    private func setupPreviewLayer() {
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.frame
        view.layer.insertSublayer(previewLayer, at: 0)
    }
}

extension CameraViewController: ErrorPresentable {
    enum Error: Swift.Error {
        case notAuthorized
        case deviceUnavailable
        case constructDeviceInputError
        case addDeviceInputError
        case addDeviceOutputError
        
        var localizedDescription: String {
            var sessionErrorMessage = ""
            switch self {
            case .notAuthorized: return "카메라 접근 권한이 없습니다."
            case .deviceUnavailable: sessionErrorMessage = "Device unavailable"
            case .constructDeviceInputError: sessionErrorMessage = "Error occur constructing device input"
            case .addDeviceInputError: sessionErrorMessage = "Error occur adding device input"
            case .addDeviceOutputError: sessionErrorMessage = "Error occur adding device output"
            }
            return NSLocalizedString("캡쳐할 수 없습니다.", comment: sessionErrorMessage)
        }
    }
    
    private func displayAlertAndClosePage(_ error: Error) {
        self.displayError(error.localizedDescription, { _ in
            self.router?.openHomeFeedPage()
        })
    }
    
    private func displayAlertWithOpenSettings(_ error: Error) {
        let openConfigAction = UIAlertAction(title: "설정으로 가기", style: .default, handler: { _ in
            self.router?.openSettings()
        })
        self.displayError(error.localizedDescription, with: [openConfigAction]) { _ in
            self.router?.openHomeFeedPage()
        }
    }
}
