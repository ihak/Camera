//
//  ViewController.swift
//  Camera
//
//  Created by Hassan Ahmed on 01/09/2017.
//  Copyright © 2017 Hassan Ahmed. All rights reserved.
//

import UIKit
import AVFoundation

enum FocusMode: Int {
    case locked
    case autoFocus
    case continuousAutoFocus
    
    static let allValues = [locked, autoFocus, continuousAutoFocus]
    
    var description: String {
        var text = "Locked"
        
        switch self {
        case .autoFocus:
            text = "Auto Focus"
        case .continuousAutoFocus:
            text = "Continuous Auto Focus"
        case .locked:
            text = "Locked"
        }
        return text
    }
    
    var avFoundationValue: AVCaptureFocusMode {
        var mode = AVCaptureFocusMode.locked
        
        switch self {
        case .autoFocus:
            mode = .autoFocus
        case .continuousAutoFocus:
            mode = .continuousAutoFocus
        case .locked:
            mode = .locked
        }
        
        return mode
    }
}

enum SessionPreset: Int {
    case photo
    case high
    case medium
    case low
    case preset352x288
    case preset640x480
    case preset1280x720
    case preset1920x1080
    case preset3840x2160
    case iFrame960x540
    case iFrame1280x720
    case InputPriority
    
    static let allValues = [photo, high, medium, low, preset352x288, preset640x480, preset1280x720, preset1920x1080, preset3840x2160, iFrame960x540, iFrame1280x720, InputPriority]
    
    var description: String {
        var text: String
        
        switch self {
        case .photo:
            text = "Photo"
        case .high:
            text = "High"
        case .medium:
            text = "Medium"
        case .low:
            text = "Low"
        case .preset352x288:
            text = "352 x 288"
        case .preset640x480:
            text = "640 x 480"
        case .preset1280x720:
            text = "1280 x 720"
        case .preset1920x1080:
            text = "1920 x 1080"
        case .preset3840x2160:
            text = "3840 x 2160"
        case .iFrame1280x720:
            text = "iFrame 1280 x 720"
        case .iFrame960x540:
            text = "iFrame960 x 540"
        case .InputPriority:
            text = "Input Priority"
        }
        
        return text
    }
    
    var avFoundationValue: String {
        var text = ""
        
        switch self {
        case .photo:
            text = AVCaptureSessionPresetPhoto
        case .high:
            text = AVCaptureSessionPresetHigh
        case .medium:
            text = AVCaptureSessionPresetMedium
        case .low:
            text = AVCaptureSessionPresetLow
        case .preset352x288:
            text = AVCaptureSessionPreset352x288
        case .preset640x480:
            text = AVCaptureSessionPreset640x480
        case .preset1280x720:
            text = AVCaptureSessionPreset1280x720
        case .preset1920x1080:
            text = AVCaptureSessionPreset1920x1080
        case .preset3840x2160:
            text = AVCaptureSessionPreset3840x2160
        case .iFrame1280x720:
            text = AVCaptureSessionPresetiFrame960x540
        case .iFrame960x540:
            text = AVCaptureSessionPresetiFrame1280x720
        case .InputPriority:
            text = AVCaptureSessionPresetInputPriority
        }
        
        return text
    }
}

enum PickerType {
    case focus
    case preset
}

class ViewController: UIViewController {

    //IBOutlets
    @IBOutlet var lockFocusButton: UIButton!
    @IBOutlet var presetButton: UIButton!
    @IBOutlet var pickerViewContainer: UIView!
    @IBOutlet var pickerView: UIPickerView!
    
    @IBOutlet weak var captureButton: UIButton!
    var pickerViewBottomConstraint: NSLayoutConstraint?
    
    let focusModes: [AVCaptureFocusMode]  = [.locked, .autoFocus, .continuousAutoFocus]
    
    let captureSession = AVCaptureSession()
    
    var currentDevice: AVCaptureDevice?
    
    var pickerType = PickerType.focus
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    var input: AVCaptureDeviceInput!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(sessionWithNoConnection: captureSession)
        videoPreviewLayer.frame = self.view.bounds
        videoPreviewLayer.videoGravity = AVLayerVideoGravityResize
        self.view.layer.insertSublayer(videoPreviewLayer, at: 0)
        
        captureSession.startRunning()
        
        applyTheme(to: lockFocusButton)
        applyTheme(to: presetButton)
        
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        self.pickerView.showsSelectionIndicator = true
    }

    override func viewWillAppear(_ animated: Bool) {
        if (self.captureSession.isRunning) {
            print("Capture Session is running")
        }
        
        
        // AVCaptureDevice.devices has been depricated
//        print("Capture devices: \(AVCaptureDevice.devices())")
        
        // Use device discovery session instead
        let deviceDiscoverySession = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInMicrophone, .builtInWideAngleCamera], mediaType: nil, position: .back)
        print("devices: \(String(describing: deviceDiscoverySession?.devices))")
        
        if let devices = deviceDiscoverySession?.devices {
            for device in devices {
                if device.hasMediaType(AVMediaTypeVideo) {
                    try? device.lockForConfiguration()
                    device.focusMode = .continuousAutoFocus
                    device.autoFocusRangeRestriction = .near
                    device.unlockForConfiguration()
                    if let input = try? AVCaptureDeviceInput(device: device) {
                        self.input = input
                        captureSession.addInputWithNoConnections(input)
                        
//                        AVCaptureInputPort
                        
                        for port in input.ports {
                            if let port = port as? AVCaptureInputPort {
                                if port.mediaType == AVMediaTypeVideo {
                                    let connection = AVCaptureConnection(inputPort: port, videoPreviewLayer: videoPreviewLayer)
                                    connection?.videoOrientation = .portraitUpsideDown
                                    self.captureSession.add(connection)
                                }
                            }
                        }
                    }
                    self.currentDevice = device
                }
            }
            
        }
        
        captureSession.beginConfiguration()
        if captureSession.canSetSessionPreset(AVCaptureSessionPresetInputPriority) {
            captureSession.sessionPreset = AVCaptureSessionPresetHigh
        }
        
        captureSession.commitConfiguration()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueShowImagePreview" {
            if let vc = segue.destination as? ImagePreviewVC {
                vc.image = sender as? UIImage
            }
        }
    }
    
    @IBAction func lockButtonTapped(_ sender: Any) {
        pickerType = .focus
        addPickerView()
    }
    
    @IBAction func presetButtonTapped(_ sender: UIButton) {
        pickerType = .preset
        addPickerView()
    }


    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        removePickerView()
    }

    @IBAction func doneButtonTapped(_ sender: AnyObject) {
        let row = self.pickerView.selectedRow(inComponent: 0)
        switch pickerType {
        case .focus:
            changeFocus(mode: FocusMode.allValues[row].avFoundationValue)
        case .preset:
            changeSessionPreset(preset: SessionPreset.allValues[row])
        }
        
        removePickerView()
    }

    @IBAction func captureButtonTapped(_ sender: UIButton) {
        let photoOutput = AVCapturePhotoOutput()
        if self.captureSession.canAddOutput(photoOutput) {
            self.captureSession.addOutputWithNoConnections(photoOutput)
        }
        
        for port in input.ports {
            if let port = port as? AVCaptureInputPort {
                if port.mediaType == AVMediaTypeVideo {
                    let connection = AVCaptureConnection(inputPorts: [port], output: photoOutput)
                    connection?.videoOrientation = .portrait
                    
                    if self.captureSession.canAdd(connection) {
                        self.captureSession.add(connection)
                        let photoSettings = AVCapturePhotoSettings()
                        photoSettings.isAutoStillImageStabilizationEnabled = true
                        photoOutput.capturePhoto(with: photoSettings, delegate: self)
                    }
                }
            }
        }
        

        
        // Use device discovery session instead
//        let deviceDiscoverySession = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInMicrophone, .builtInWideAngleCamera], mediaType: nil, position: .back)
//        print("devices: \(String(describing: deviceDiscoverySession?.devices))")
//        
//        if let devices = deviceDiscoverySession?.devices {
//            for device in devices {
//                if device.hasMediaType(AVMediaTypeVideo) {
//                    try? device.lockForConfiguration()
//                    device.focusMode = .continuousAutoFocus
//                    device.autoFocusRangeRestriction = .near
//                    device.unlockForConfiguration()
//                    if let input = try? AVCaptureDeviceInput(device: device) {
//                        self.input = input
//                        captureSession.addInputWithNoConnections(input)
//                        
//                        //                        AVCaptureInputPort
//                        
//                        for port in input.ports {
//                            if let port = port as? AVCaptureInputPort {
//                                if port.mediaType == AVMediaTypeVideo {
//                                    let connection = AVCaptureConnection(inputPorts: [port], output: photoOutput)
//                                    connection?.videoOrientation = .portraitUpsideDown
//                                    
//                                    if self.captureSession.canAdd(connection) {
//                                        self.captureSession.add(connection)
//                                        photoOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
//                                    }
//                                }
//                            }
//                        }
//                    }
//                    self.currentDevice = device
//                }
//            }
//        }
    }
    
    func changeFocus(mode: AVCaptureFocusMode) {
        if let currentDevice = self.currentDevice {
            do {
                try currentDevice.lockForConfiguration()
                currentDevice.focusMode = mode
                currentDevice.unlockForConfiguration()
                
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    func changeSessionPreset(preset: SessionPreset) {
        if captureSession.canSetSessionPreset(preset.avFoundationValue) {
            captureSession.sessionPreset = preset.avFoundationValue
        }
        else {
            showAlert(title: "Unsupported Preset", message: "Preset \'\(preset.description)\' is not supported on this device.", viewController: self)
        }
    }
    
    func applyTheme(to button: UIButton) {
        button.backgroundColor = UIColor.white.withAlphaComponent(0.75)
        button.layer.cornerRadius = 5.0
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.darkGray.cgColor
    }
    
    func showAlert(title: String, message: String, viewController: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
}


extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func addPickerView() {
        self.view.addSubview(pickerViewContainer)
        self.pickerViewContainer.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"H:|[view]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": pickerViewContainer]))
        self.pickerViewBottomConstraint = NSLayoutConstraint(item: pickerViewContainer, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        self.view.addConstraint(self.pickerViewBottomConstraint!)
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        self.pickerViewBottomConstraint?.isActive = false
        self.pickerViewBottomConstraint = NSLayoutConstraint(item: pickerViewContainer, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        self.view.addConstraint(self.pickerViewBottomConstraint!)
        
        UIView.animate(withDuration: 0.2) {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }
    
    func removePickerView() {
        self.pickerViewBottomConstraint?.isActive = false
        self.pickerViewBottomConstraint = NSLayoutConstraint(item: pickerViewContainer, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        self.view.addConstraint(self.pickerViewBottomConstraint!)
        
        UIView.animate(withDuration: 0.2, animations: { 
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }) { (finished) in
            if finished {
                self.pickerViewContainer.removeFromSuperview()
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var count = 0
        
        switch pickerType {
        case .focus:
            count = FocusMode.allValues.count
        case .preset:
            count = SessionPreset.allValues.count
        }
        return count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var title = ""
        
        switch pickerType {
        case .focus:
            title = FocusMode.allValues[row].description
                if let currentDevice = self.currentDevice {
                    if currentDevice.focusMode == FocusMode.allValues[row].avFoundationValue {
                        pickerView.selectRow(row, inComponent: component, animated: false)
                    }
                }
        case .preset:
            title = SessionPreset.allValues[row].description
            if captureSession.sessionPreset == SessionPreset.allValues[row].avFoundationValue {
                pickerView.selectRow(row, inComponent: component, animated: false)
            }
        }
        
        return title
    }
}

extension ViewController: AVCapturePhotoCaptureDelegate {
    func capture(_ captureOutput: AVCapturePhotoOutput, willBeginCaptureForResolvedSettings resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("begin capture")
    }
    
    func capture(_ captureOutput: AVCapturePhotoOutput, willCapturePhotoForResolvedSettings resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("will capture")
    }
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didCapturePhotoForResolvedSettings resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("did capture")
    }
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        //
        if let error = error {
            print(error.localizedDescription)
        }
        else {
            if let sampleBuffer = photoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: nil) {
                let image = UIImage(data: dataImage)
                print(image)
                
                DispatchQueue.main.async {
                    self.moveToImagePreviewVC(withImage: image!)
                }
            }
        }
    }
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingRawPhotoSampleBuffer rawSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let photoSampleBuffer = rawSampleBuffer {
            let itemCount = CMSampleBufferGetNumSamples(photoSampleBuffer)
            
            let imageBuffer: CVImageBuffer = CMSampleBufferGetImageBuffer(photoSampleBuffer)!
            if let imgBuffer = CMSampleBufferGetImageBuffer(photoSampleBuffer) {
                let displaySize = CVImageBufferGetDisplaySize(imgBuffer)
                let encodedSize = CVImageBufferGetEncodedSize(imgBuffer)
            }
            
        }
    }
    
    func moveToImagePreviewVC(withImage image:UIImage) {
        self.performSegue(withIdentifier: "SegueShowImagePreview", sender: image)
    }
}
