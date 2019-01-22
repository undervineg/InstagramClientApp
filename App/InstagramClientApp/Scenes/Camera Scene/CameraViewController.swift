//
//  CameraViewController.swift
//  InstagramClientApp
//
//  Created by 심승민 on 22/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit
import AVFoundation
import InstagramEngine

final class CameraViewController: UIViewController {
    // MARK: UI Properties
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var photoCapturedView: PhotoCapturedView?
    
    private var isPhotoCapturedViewShowing: Bool {
        get { return !(photoCapturedView?.isHidden ?? true) }
        set(v) { photoCapturedView?.isHidden = !v }
    }
    
    // MARK: Private Properties
    private var router: CameraRouter.Routes?
    private let captureSession: AVCaptureSession = AVCaptureSession()
    private var isSessionRunning: Bool = false
    private var photoOutput: AVCapturePhotoOutput?
    private var capturedDelegate: CameraCaptureProcessor?
    
    // MARK: Init
    convenience init(router: CameraRouter.Routes) {
        self.init()
        self.router = router
    }
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.checkDeviceAuthorization {
            self.displayAlertWithOpenSettings($0)
        }
        self.configureSession {
            self.displayAlertAndClosePage($0)
        }
        
        setupPreviewLayer()
        setupPhotoCapturedView()
        
        self.captureSession.startRunning()
        self.isSessionRunning = true
    }
    
    private func setupPhotoCapturedView() {
        let photoCapturedView = PhotoCapturedView(frame: view.frame)
        view.addSubview(photoCapturedView)
        photoCapturedView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            photoCapturedView.topAnchor.constraint(equalTo: view.topAnchor),
            photoCapturedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            photoCapturedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            photoCapturedView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        self.photoCapturedView = photoCapturedView
        isPhotoCapturedViewShowing = false
    }
    
    // MARK: Actions
    @IBAction func captureButtonDidTap(_ sender: UIButton) {
        guard isSessionRunning else { return }
        
        if let previewLayerOrientation = previewLayer?.connection?.videoOrientation {
            let photoOutputConnection = photoOutput?.connection(with: .video)
            photoOutputConnection?.videoOrientation = previewLayerOrientation
        }
        
        guard let photoOutput = self.photoOutput else { return }

        let settings = AVCapturePhotoSettings()
        guard let previewFormatType = settings.availablePreviewPhotoPixelFormatTypes.first else { return }
        settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewFormatType]
        let processor = CameraCaptureProcessor(photoOutput: photoOutput, settings: settings)
        self.capturedDelegate = processor
        
        processor.finishProcessingPhotoCompletion = setCapturedImage
        
        processor.capturePhoto()
    }
    
    private func setCapturedImage(_ result: Result<Data, Error>) {
        switch result {
        case .success(let photoData):
            isPhotoCapturedViewShowing = true
            photoCapturedView?.capturedImageView.image = UIImage(data: photoData)
        case .failure(let error):
            print(error)
        }
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
        self.photoOutput = output
        
        captureSession.commitConfiguration()
    }
    
    private func checkDeviceAuthorization(_ completion: @escaping (Error) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: return
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                granted ? nil : completion(.notAuthorized)
            }
        default: completion(.notAuthorized)
        }
    }
    
    private func setupPreviewLayer() {
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.frame
        view.layer.insertSublayer(previewLayer, at: 0)
        self.previewLayer = previewLayer
    }
}

extension CameraViewController: ErrorPresentable {
    enum Error: Swift.Error {
        case notAuthorized
        case deviceUnavailable
        case constructDeviceInputError
        case addDeviceInputError
        case addDeviceOutputError
        case photoProcessingError
        case photoDataNotExist
        
        var localizedDescription: String {
            var sessionErrorMessage = ""
            switch self {
            case .notAuthorized: return "카메라 접근 권한이 없습니다."
            case .photoProcessingError, .photoDataNotExist: return "캡쳐 중 문제가 발생했습니다."
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
