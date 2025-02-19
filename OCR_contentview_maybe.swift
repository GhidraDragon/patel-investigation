import SwiftUI
import PDFKit
import Vision

struct ContentView: View {
    @State private var pdfURL: URL?
    @State private var recognizedText: [String: String] = [:]
    
    var body: some View {
        VStack {
            Button("Select PDF & Run OCR") {
                let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf])
                picker.delegate = PickerDelegate { url in
                    self.pdfURL = url
                    if let safeURL = url {
                        self.recognizedText = extractTextFromPDF(safeURL)
                        saveTextFile(recognizedText: self.recognizedText)
                    }
                }
                UIApplication.shared.windows.first?.rootViewController?.present(picker, animated: true)
            }
            if !recognizedText.isEmpty {
                Text("OCR Results Saved.")
            }
        }
    }
}

class PickerDelegate: NSObject, UIDocumentPickerDelegate {
    let completion: (URL?) -> Void
    init(completion: @escaping (URL?) -> Void) { self.completion = completion }
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        completion(urls.first)
    }
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        completion(nil)
    }
}

func extractTextFromPDF(_ pdfURL: URL) -> [String: String] {
    guard let pdfDoc = PDFDocument(url: pdfURL) else { return [:] }
    var results = [String: String]()
    for i in 0..<pdfDoc.pageCount {
        guard let page = pdfDoc.page(at: i) else { continue }
        let label = page.label ?? "Page \(i+1)"
        if let pageImage = pageImageForVision(page: page),
           let cgImage = pageImage.cgImage {
            results[label] = runVisionOCR(cgImage: cgImage, pageBounds: page.bounds(for: .mediaBox))
        }
    }
    return results
}

func pageImageForVision(page: PDFPage) -> UIImage? {
    let scale: CGFloat = 0.5
    let bounds = page.bounds(for: .mediaBox)
    let targetSize = CGSize(width: bounds.width * scale, height: bounds.height * scale)
    let renderer = UIGraphicsImageRenderer(size: targetSize)
    return renderer.image { ctx in
        ctx.cgContext.scaleBy(x: scale, y: scale)
        page.draw(with: .mediaBox, to: ctx.cgContext)
    }
}

func runVisionOCR(cgImage: CGImage, pageBounds: CGRect) -> String {
    var recognizedText = ""
    let request = VNRecognizeTextRequest { req, _ in
        guard let obs = req.results as? [VNRecognizedTextObservation] else { return }
        for o in obs {
            if let topCandidate = o.topCandidates(1).first {
                recognizedText += topCandidate.string + "\n"
            }
        }
    }
    request.recognitionLevel = .fast
    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    try? handler.perform([request])
    return recognizedText
}

func saveTextFile(recognizedText: [String: String]) {
    let combined = recognizedText.map { "\($0.key)\n\($0.value)\n" }.joined()
    let fm = FileManager.default
    let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
    let fileURL = docs.appendingPathComponent("OCR_Results.txt")
    try? combined.write(to: fileURL, atomically: true, encoding: .utf8)
}