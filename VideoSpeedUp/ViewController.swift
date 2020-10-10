
import  Photos
import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = Bundle.main.url(forResource: "monkey", withExtension: "mp4")!
        VSVideoSpeeder.shared.scaleAsset(fromURL: url, by: 3, withMode: .Faster) { [weak self] exporter in
             if let exporter = exporter {
                 switch exporter.status {
                        case .failed: do {
                              print(exporter.error?.localizedDescription ?? "Error in exporting..")
                        }
                        case .completed: do {
                              print("Scaled video has been generated successfully!")
                            
                            guard let outputURL = exporter.outputURL else {
                              return
                            }
                            self?.saveVideo(outputURL)
                        }
                        case .unknown: break
                        case .waiting: break
                        case .exporting: break
                        case .cancelled: break
                 @unknown default:
                    break
                 }
              }
        }
    }
    
    private func saveVideo(_ outputURL: URL) {
        let saveVideoToPhotos = {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL)
        }) { [weak self] saved, error in
            let success = saved && (error == nil)
            let message = success ? "Video saved" : "Failed to save video"

            DispatchQueue.main.async {
                let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }
          }
        }
        if PHPhotoLibrary.authorizationStatus() != .authorized {
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    saveVideoToPhotos()
                }
            }
        } else {
            saveVideoToPhotos()
        }
    }

}
