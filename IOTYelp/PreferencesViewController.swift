//
//  PreferencesViewController
//  IOTYelp
//
//  Created by Alla Bondarenko on 2016-11-15.
//  Copyright © 2016 Alla Bondarenko. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class PreferencesViewController: UIViewController, FBSDKLoginButtonDelegate,  UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate, CategoriesLayoutDelegate, BluemixAPIControllerProtocol {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    @IBOutlet weak var addTerm: UITextField!
    @IBOutlet weak var categoryContainerView: UICollectionView!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    
    var personalityApi: PersonalityInsightsAPI!
    var yelpAPI: YelpAPIController!
    var term: String?
    var categories = [Category]()
    let reuseIdentifier = "CellIdentifier"
    
    
    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(PreferencesViewController.keyboardWillShow(_:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PreferencesViewController.keyboardWillHide(_:)), name: Notification.Name.UIKeyboardWillHide , object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionLabel.text = "To see the most accurate place suggestions please log in with Facebook and enter a search term."
        
        addTerm.delegate = self
        
        categoryContainerView.dataSource = self
        categoryContainerView.delegate = self
        
        personalityApi = PersonalityInsightsAPI(delegate: self)
        
        if let layout = categoryContainerView?.collectionViewLayout as? CategoriesLayout {
            layout.delegate = self
        }
        
        if let savedCategories = loadCategories() {
            categories += savedCategories
        }
        
        
        if (FBSDKAccessToken.current() != nil) {
            returnUserData()
        } else {
            fbLoginButton.readPermissions = ["public_profile", "user_posts"]
            fbLoginButton.delegate = self
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    // MARK: Notifications
    
    func keyboardWillShow(_ notification: Notification) {
        updateBottomLayoutConstraintWithNotification(notification: notification)
    }
    
    func keyboardWillHide(_ notification: Notification) {
        updateBottomLayoutConstraintWithNotification(notification: notification)
    }
    
    //MARK: Update Constraints
    func updateBottomLayoutConstraintWithNotification(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let convertedKeyboardEndFrame = view.convert(keyboardEndFrame, from: view.window)
        let rawAnimationCurve = (notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).uint32Value << 16
        let animationCurve =  UIViewAnimationOptions(rawValue: UInt(rawAnimationCurve))
        
        bottomLayoutConstraint.constant = view.bounds.maxY - convertedKeyboardEndFrame.minY
        
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: animationCurve, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        
    }
    
    //MARK: FB Delegate methods
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if ((error) != nil) {
            //handle error present VC
            self.presentAlert(title: "Error", message: "Unable to login to Facebook account", action: UIAlertAction(title: "OK", style: .default, handler: nil))
        } else {
            print("didCompleteWithResult")
            returnUserData() 
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
        //handle
    }
    
    func returnUserData() {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/posts?limit=100&fields=message", parameters: nil)
        graphRequest.start(completionHandler: { (connection, result, error) -> Void in
            
            if ((error) != nil) {
                // Process error
                print("Error: \(error)")
                self.presentAlert(title: "Error", message: "Error retrieving posts. Please enable the permissions or enter the categories manually", action: nil)
            } else {
                if let result = result as? [String: Any] {
                    // print("fetched user: \(result)")
                    if let posts = result["data"] as? [[String: Any]] {
                        var personalityProfile = [String]()
                        for post in posts {
                            if let text : String = post["message"] as? String{
                                personalityProfile.append(text)
                            }
                        }
                        if (personalityProfile.count > 0) {
                            self.personalityApi.getPersonalityProfile(personalityData: personalityProfile)
                        }
                    
                    } else {
                        //HANDLE
                        
                    }
                }
            }
        })
    }
    
    
    //MARK: Bluemix API Protocol
    
    func didRecievePersonalityInsightsResults(_ results: [[String: Any]], error: Error?){
        DispatchQueue.main.async(execute: {
            if (error != nil) {
                //handle
            } else {
                self.categories.removeAll()
                for case let result in results{
                    if let newCategory = Category.parseWithJSON(json: result) {
                        self.categories.append(newCategory)
                    }
                    DispatchQueue.main.async(execute: {
                        self.categoryContainerView.reloadData()
                    })
                }
            }
        })
    }
    

    
    //Categories in TextField
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == addTerm {
            self.term = textField.text
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == addTerm {
            textField.resignFirstResponder()
            return false
        }
        return true
    }

    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowResults" {
                let destinationViewController = segue.destination as! UINavigationController
                let resultsTableViewController = destinationViewController.topViewController as! ResultsTableViewController
            
                resultsTableViewController.categories = self.categories
                resultsTableViewController.term = term ?? ""
        }
    }
    
    
    
    //MARK: Collection View Delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        // Configure cell
        cell.categoryName.text = categories[indexPath.row].categoryName
        cell.layer.cornerRadius = 9
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView,
                        widthForAnnotationAtIndexPath indexPath: IndexPath, withHeight height: CGFloat) -> CGFloat {
        let annotationPadding = CGFloat(6.0)
        let category = categories[indexPath.item].categoryName
        var width = annotationPadding +  CGFloat(category.characters.count * 21) + annotationPadding
        width = width >= (collectionView.bounds.width) ? collectionView.bounds.width : width
        
        return width
    }
    
    //MARK: Error Alert
    func presentAlert(title: String, message: String, action: UIAlertAction?){
        let alertController = UIAlertController(title: title, message: message, preferredStyle:.alert)
        if let action = action {
             alertController.addAction(action)
        }
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK: NSCoding
    
    func saveCategories() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(categories, toFile: Category.ArchiveURL.path)
        
        if !isSuccessfulSave {
            print("Failed to save categories..")
        }
    }
    
    func loadCategories() -> [Category]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Category.ArchiveURL.path) as? [Category]
    }
    
}
