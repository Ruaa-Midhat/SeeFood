//
//  ViewController.swift
//  SeeFood
//
//  Created by Ruaa Alzurqan on 19/03/2022.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
       // imagePicker.sourceType = .camera  to access my camera instead of photoLibrary when i tapped on camera button
        imagePicker.allowsEditing = false
        
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {//this method tells the app that the user has picked the image or movie
    
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
      
        imageView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage)//convert uiimage to ciimage
            else {fatalError("could not convert UIImage to CIImage")}
            detect(image: ciimage)
         }
        imagePicker.dismiss(animated: true, completion: nil)
      }

   // method proocess the ciimage and get classification out of it
    func detect(image: CIImage) {
        guard  let model = try? VNCoreMLModel(for: Inceptionv3().model)//upload the model
                //VNCoreMLModel : from Vision framework container of MLModel to process the image
                //model to classify the image
        else{fatalError("Loading CoreML Model Failed.")}
        
        //make a request to ask model to classify what the data you want passed in
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results =  request.results as? [VNClassificationObservation]
                    //VNClassificationObservation An object that represents classification information that an image analysis request produces.
            else{fatalError("Model failed to process image.")}
            if let firstResult = results.first{
                if firstResult.identifier.contains("hotdog"){
                    self.navigationItem.title = "Hotdog"
                } else {
                    self.navigationItem.title = "Not Hotdog"
                }
            }
        }
//firstResult contains:
//firstResult.identifier: the (prediction) name of image such as : "cliff, drop, drop-off"
//firstResult.percentage confidence: number of the confidence of image, such as: confidence=0.361167
        let handler = VNImageRequestHandler(ciImage: image) // to konw the data that you passed in using handler
        do{
            try! handler.perform([request])//using handler to perform classifying the image
        } catch{
            print(error)
        }
        
    }
     
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil) //to pick an image when the camera tapped
    }
    
}

