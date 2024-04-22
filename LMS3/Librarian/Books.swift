//
//  Books.swift
//  LMS3
//
//  Created by Aditya Majumdar on 21/04/24.
//

import UIKit
import AVFoundation
import FirebaseFirestore

struct BookDetails {
    let title: String
    let authors: [String]
    let publicationDate: String
    let genre: String
    let isbn: String
}

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCamera()
    }

    func setupUI() {
        view.backgroundColor = .white
        
        // Scan Button
        let scanButton = UIButton(type: .system)
        scanButton.setImage(UIImage(systemName: "barcode.viewfinder"), for: .normal)
        scanButton.tintColor = .systemBlue
        scanButton.addTarget(self, action: #selector(scanButtonTapped), for: .touchUpInside)
        scanButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scanButton)
        
        // Constraint for Scan Button
        NSLayoutConstraint.activate([
            scanButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc func scanButtonTapped() {
        if captureSession?.isRunning == false {
            startBarcodeScanning()
        }
    }

    func setupCamera() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            self.captureSession = AVCaptureSession()
            
            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
                print("Failed to get video capture device")
                return
            }
            
            do {
                let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
                if self.captureSession.canAddInput(videoInput) {
                    self.captureSession.addInput(videoInput)
                } else {
                    print("Failed to add video input to capture session")
                    return
                }
                
                let metadataOutput = AVCaptureMetadataOutput()
                if self.captureSession.canAddOutput(metadataOutput) {
                    self.captureSession.addOutput(metadataOutput)
                    
                    metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                    metadataOutput.metadataObjectTypes = [.ean13, .ean8]
                } else {
                    print("Failed to add metadata output to capture session")
                    return
                }
                
                DispatchQueue.main.async { [weak self] in
                    self?.previewLayer = AVCaptureVideoPreviewLayer(session: self!.captureSession)
                    self?.previewLayer.frame = self!.view.layer.bounds
                    self?.previewLayer.videoGravity = .resizeAspectFill
                    self?.view.layer.addSublayer(self!.previewLayer)
                    
                    self?.captureSession.startRunning()
                }
            } catch {
                print("Error setting up camera: \(error.localizedDescription)")
            }
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let isbn = metadataObject.stringValue else {
            print("No valid ISBN found")
            return
        }
        
        stopBarcodeScanning() // Stop scanning after successful read
        fetchBookDetails(isbn: isbn)
    }

    func fetchBookDetails(isbn: String) {
        let apiUrl = "https://openlibrary.org/api/books?bibkeys=ISBN:\(isbn)&format=json&jscmd=data"
        
        guard let url = URL(string: apiUrl) else {
            print("Invalid API URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                
                if let bookDetailsJSON = json?["ISBN:\(isbn)"] as? [String: Any] {
                    let title = bookDetailsJSON["title"] as? String ?? "Unknown Title"
                    let authors = (bookDetailsJSON["authors"] as? [[String: Any]] ?? []).compactMap { $0["name"] as? String }
                    let publicationDate = bookDetailsJSON["publish_date"] as? String ?? "Unknown"
                    let genres = (bookDetailsJSON["subjects"] as? [[String: Any]] ?? []).compactMap { $0["name"] as? String }
                    let genre = genres.joined(separator: ", ")
                    
                    let book = BookDetails(title: title, authors: authors, publicationDate: publicationDate, genre: genre, isbn: isbn)
                    
                    self?.saveBookToFirestore(book: book)
                } else {
                    print("Book details not found for ISBN: \(isbn)")
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }.resume()
    }

    func saveBookToFirestore(book: BookDetails) {
        let booksRef = db.collection("books")
        
        let data: [String: Any] = [
            "title": book.title,
            "authors": book.authors,
            "publication_date": book.publicationDate,
            "genre": book.genre,
            "isbn": book.isbn
        ]
        
        booksRef.addDocument(data: data) { error in
            if let error = error {
                print("Error adding document: \(error.localizedDescription)")
            } else {
                print("Document added successfully!")
            }
        }
    }

    func stopBarcodeScanning() {
        guard let captureSession = captureSession, captureSession.isRunning else { return }
        captureSession.stopRunning()
    }
  
    func startBarcodeScanning() {
        guard let captureSession = captureSession, !captureSession.isRunning else { return }
        captureSession.startRunning()
    }
}
