//
//  QRCodePickerView.swift
//  QRWidget
//
//  Created by Haruta Yamada on 2020/10/08.
//

import SwiftUI
import UIKit
import AVFoundation

class QRCodePickerViewModel: ObservableObject {
    enum State {
        case shouldSetups
        case canStartRunning
        case captured(code: String)
    }
    @Published var state: State = .shouldSetups
}

struct QRCodePickerView: UIViewRepresentable {
    @ObservedObject var viewModel: QRCodePickerViewModel
    @Binding var destination: Destination?
    @Environment(\.managedObjectContext) var viewContext
    var captured: () -> Void = {}
    init(destination: Binding<Destination?>) {
        self._destination = destination
        self.viewModel = QRCodePickerViewModel()
    }
    func makeCoordinator() -> Coordinator {
        .init(viewModel: viewModel)
    }
    
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var previewLayer: CALayer?
        let captureSession = AVCaptureSession()
        let viewModel: QRCodePickerViewModel
        init(viewModel: QRCodePickerViewModel) {
            self.viewModel = viewModel
            super.init()
        }
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            metadataObjects
                .compactMap { $0 as? AVMetadataMachineReadableCodeObject }
                .filter { $0.type == AVMetadataObject.ObjectType.qr }
                .compactMap { $0.stringValue }
                .forEach { code in
                    if case .captured(code: _) = viewModel.state { return }
                    viewModel.state = .captured(code: code)
                }
        }
        func setupInputOutput() {
            AVCaptureDevice.requestAccess(for: .video) { [weak self] canAccessDevice in
                guard canAccessDevice, let self = self, case .shouldSetups = self.viewModel.state else {
                    return
                }
                self.captureSession.beginConfiguration()
                let videoDevice = AVCaptureDevice.default(for: .video)
                guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!), self.captureSession.canAddInput(videoDeviceInput) else {
                    return
                }
                self.captureSession.addInput(videoDeviceInput)
                let metadataOutput = AVCaptureMetadataOutput()
                metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
                self.captureSession.addOutput(metadataOutput)
                metadataOutput.metadataObjectTypes = [.qr]
                self.captureSession.commitConfiguration()
                DispatchQueue.main.async {
                    self.viewModel.state = .canStartRunning
                }
            }
        }
    }
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let previewLayer = AVCaptureVideoPreviewLayer(session: context.coordinator.captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        context.coordinator.previewLayer = previewLayer
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        let session = context.coordinator.captureSession
        if case .shouldSetups = viewModel.state {
            context.coordinator.setupInputOutput()
        } else if !session.isRunning, case .canStartRunning = viewModel.state  {
            session.startRunning()
        } else if case .captured(let code) = viewModel.state, self.destination == .picker {
            let widget = WidgetModel(context: viewContext)
            widget.code = code
            self.destination = .editor(widget: widget)
        }
        context.coordinator.previewLayer?.frame = uiView.bounds
    }
    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        coordinator.captureSession.stopRunning()
    }
}

struct QRCodePickerView_Previews: PreviewProvider {
    static var previews: some View {
        QRCodePickerView(destination: .constant(nil))
    }
}
