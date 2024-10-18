//
//  FormVC.swift
//  XITechMT
//
//  Created by Dev Rana on 17/10/24.
//

import UIKit

class FormVC: UIViewController {
    @IBOutlet weak var imgMain: UIImageView!
    
    @IBOutlet weak var tfFirstName: UITextField!
    @IBOutlet weak var tfLastName: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPhone: UITextField!
    
    @IBOutlet weak var btnSubmit: UIButton!{
        didSet{
            btnSubmit.layer.borderColor = UIColor.black.cgColor
            btnSubmit.layer.borderWidth = 1
        }
    }
    
    @IBOutlet weak var btnSelectImg: UIButton!
    
    var imagePicker = UIImagePickerController()
    
    var selectedImage : Data? = nil
    
    private var progressView: UIProgressView?
    private var alertController: UIAlertController?
    private var uploadTask: URLSessionUploadTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tfDelegateCalls()
    }
    
    func tfDelegateCalls(){
        tfFirstName.delegate = self
        tfLastName.delegate = self
        tfEmail.delegate = self
        tfPhone.delegate = self
    }
    
    @IBAction func btnSelectImgAction(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnSubmitAction(_ sender: UIButton) {
        self.validate()
    }
}

extension FormVC {
    func validate() {
        guard selectedImage != nil else {
            Toast.showToast(message: "Please select an image.")
            return
        }
        
        guard let firstName = tfFirstName.text, !firstName.isFieldEmpty() else {
            Toast.showToast(message: "Please enter your first name.")
            return
        }
        
        guard let lastName = tfLastName.text, !lastName.isFieldEmpty() else {
            Toast.showToast(message: "Please enter your last name.")
            return
        }
        
        guard let email = tfEmail.text, !email.isFieldEmpty() else {
            Toast.showToast(message: "Please enter your email.")
            return
        }
        
        guard email.isValidEmail() else {
            Toast.showToast(message: "Please enter a valid email.")
            return
        }
        
        guard let phone = tfPhone.text, !phone.isFieldEmpty() else {
            Toast.showToast(message: "Please enter your phone number.")
            return
        }
        
        guard phone.isPhoneNumberValid() else {
            Toast.showToast(message: "Please enter a valid phone number.")
            return
        }
        
        let param: [String: Any] = [
            "first_name": firstName,
            "last_name": lastName,
            "email": email,
            "phone": phone
        ]
        
        postData(params: param, img: self.selectedImage!) {
            self.navigationController?.popViewController(animated: true)
        }
    }
}


extension FormVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.imgMain.image = image
            self.selectedImage = image.jpegData(compressionQuality: 1.0)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.delegate = nil
        picker.dismiss(animated: true, completion: nil)
    }
}

extension FormVC : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfFirstName {
            tfLastName.becomeFirstResponder()
        } else if textField == tfLastName {
            tfEmail.becomeFirstResponder()
        } else if textField == tfEmail{
            tfPhone.becomeFirstResponder()
        }else if textField == tfPhone{
            tfPhone.resignFirstResponder()
        }
        return true
    }
}

extension FormVC {
    func showAlertWithProgress() {
        let alertController = UIAlertController(title: "Uploading...", message: "Progress: 0%", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {[weak self] action in
            guard let self = self else {return}
            self.uploadTask?.cancel()
        }
        alertController.addAction(cancelAction)
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progress = 0.0
        progressView.translatesAutoresizingMaskIntoConstraints = false
        alertController.view.addSubview(progressView)
        
        NSLayoutConstraint.activate([
            progressView.bottomAnchor.constraint(equalTo: alertController.view.bottomAnchor, constant: -45),
            progressView.leftAnchor.constraint(equalTo: alertController.view.leftAnchor),
            progressView.rightAnchor.constraint(equalTo: alertController.view.rightAnchor)
        ])

        self.present(alertController, animated: true, completion: nil)
        
        self.progressView = progressView
        self.alertController = alertController
    }
}

extension FormVC: URLSessionTaskDelegate {
    typealias ResultCompletionMultipart = () -> Void

    func postData(params: [String: Any], img: Data, completion: @escaping ResultCompletionMultipart) {
        guard let url = URL(string: "http://dev3.xicomtechnologies.com/xttest/savedata.php") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        for (key, value) in params {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        let imageKey = "user_image"
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(imageKey)\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(img)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        self.showAlertWithProgress()
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        self.uploadTask = session.uploadTask(with: request, from: body) {[weak self] data, response, error in
            guard let self = self else { return }
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            guard let data = data else {
                print("No data received")
                return
            }
            do {
                let jsonData = try JSONDecoder().decode(FormModel.self, from: data)
                print("Response jsonData: \(jsonData)")
                
                DispatchQueue.main.async {
                    self.alertController?.dismiss(animated: true, completion: nil)
                    Toast.showToast(message: jsonData.message ?? "")
                    completion()
                }
            } catch {
                print("JSON parsing error: \(error.localizedDescription)")
            }

        }
        self.uploadTask?.resume()
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        DispatchQueue.main.async {
            let progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
            self.progressView?.setProgress(progress, animated: true)
            self.alertController?.message = "Progress: \(Int(progress * 100))%"
        }
    }
}
