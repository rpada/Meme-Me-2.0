//
//  MemeCreationViewController.swift
//  Image Picker
//
//  Created by Rianne Pada on 4/8/22.
//
import UIKit
class ViewController: UIViewController, UIImagePickerControllerDelegate,
                      UINavigationControllerDelegate, UITextFieldDelegate
{
 
    @IBOutlet weak var shareToolbar: UIToolbar!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var PickImage: UIToolbar!
    @IBOutlet weak var TopText: UITextField!
    @IBOutlet weak var BottomText: UITextField!
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var ButtonShare: UIBarButtonItem!
            
    override func viewDidLoad() {
        
        super.viewDidLoad()
        ButtonShare.isEnabled = false
        setupTextField(textField: TopText)
        setupTextField(textField: BottomText)
        TopText.delegate = self
        BottomText.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
            cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        super.viewWillAppear(animated)
           subscribeToKeyboardNotifications()
        // from Udacity iOS Development course, Lesson 4 section 12
        }
    
    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        // from Udacity iOS Development course, Lesson 4 section 12
    }

    func setupTextField(textField: UITextField) {
            //setting default attributes
            let memetextAttributes: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.strokeColor: UIColor.black ,
                NSAttributedString.Key.foregroundColor: UIColor.white ,
                NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
                NSAttributedString.Key.strokeWidth: -4.5
            ]
        textField.defaultTextAttributes = memetextAttributes
        textField.textAlignment = .center
        textField.delegate = self
        }
    // when you click 'Cancel' button, view disappears

    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    // from Udacity iOS Development course, Lesson 4 section 5
    @IBAction func pickImage(_ imageSource: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
             imagePicker.delegate = self
             imagePicker.sourceType = imageSource
             present(imagePicker, animated: true, completion: nil)
    }
    // from Udacity iOS Development course, Lesson 4 section 7
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePickerView.image = image
        }
        ButtonShare.isEnabled = true
        dismiss(animated: true, completion: nil)
    }
    // from Udacity iOS Development course, Lesson 4 section 8
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        self.pickImage(.photoLibrary)    }
    // from Udacity iOS Development course, Lesson 4 section 8
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        self.pickImage(.camera)
       }
  
    // from https://stackoverflow.com/questions/41537721/how-to-hide-keyboard-when-return-key-is-hit-swift
    // makes the keyboard disappear once you click return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true;
    }
    
    // from Udacity iOS Development course, Lesson 4 section 15
  
    // from Udacity iOS Development course, Lesson 4 section 15
    func generateMemedImage() -> UIImage {
        // TODO: Hide toolbar and navbar
        // from https://stackoverflow.com/questions/32573744/ios-swift-hide-and-unhide-nav-and-tool-bars
        func hideAllBars(_ hide: Bool) {
            if hide {
                PickImage.isHidden = true
                shareToolbar.isHidden = true
            } else {
                PickImage.isHidden = false
                shareToolbar.isHidden = false
            }
        }
        hideAllBars(true)
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let finalImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        // TODO: Show toolbar and navbar
        hideAllBars(false)
        return finalImage
    }
    
    @IBAction func shareMemeImage(_ sender: UIBarButtonItem){
        let memeImage = generateMemedImage()
       
        let activityViewController = UIActivityViewController(activityItems: [memeImage], applicationActivities: nil)
        
        activityViewController.completionWithItemsHandler = { (activityType, completed, returnedItems, activityError) -> () in
            if (completed) {
                self.save()
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        self.present(activityViewController, animated: true, completion: nil)
       
    }
    func save() {
        // Create the meme
        let memeImage = generateMemedImage()
        let meme = Meme(topText: TopText.text!, bottomText: BottomText.text!, originalImage: imagePickerView.image!, memedImage: memeImage)
        
        // Add it to the memes array in the Application Delegate
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
    }
    // from Udacity iOS Development course, Lesson 4 section 12
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    // from Udacity iOS Development course, Lesson 4 section 12
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // from https://stackoverflow.com/questions/26070242/move-view-with-keyboard-using-swift/34637353
    // and help from Udacity iOS Development course, Lesson 4 section 13
        @objc func keyboardWillHide(_ notification:Notification){
            view.frame.origin.y = 0
        }
    // from Udacity iOS Development course, Lesson 4 section 12
    @objc func keyboardWillShow(_ notification:Notification) {
        if BottomText.isEditing {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    // from Udacity iOS Development course, Lesson 4 section 12
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    
   
}

