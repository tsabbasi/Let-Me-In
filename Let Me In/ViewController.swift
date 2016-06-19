//
//  ViewController.swift
//  Let Me In
//
//  Created by Taha Abbasi on 6/18/16.
//  Copyright © 2016 Web N App. All rights reserved.
//

import UIKit
import Firebase
import Toast_Swift
import FBSDKLoginKit

class ViewController: UIViewController, UITextFieldDelegate, GIDSignInUIDelegate {
    

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginWithFacebookButton: UIButton!
    
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    
    @IBAction func loginFacebookButtonPressed(sender: AnyObject) {
        
        let loginWithFacebook : FBSDKLoginManager = FBSDKLoginManager()
        
        loginWithFacebook.logInWithReadPermissions(["public_profile", "email"], fromViewController: self) { (result: FBSDKLoginManagerLoginResult!, error: NSError!) in
            
            if let error = error {
                self.showErrorToast(error.localizedDescription)
            } else if let result = result {
                if result.isCancelled {
                    self.showErrorToast("Cancelled")
                } else {
                    self.showErrorToast("Logged in")
                    
                    let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
                    
                    self.userSignInWithSocialAuth(credential)
                }
            }
        }
    }
    
    
    @IBAction func signOutButtonPressed(sender: AnyObject) {
        userSignOut()
        
    }
    @IBAction func signInButtonPressed(sender: AnyObject) {
        
        email.resignFirstResponder()
        password.resignFirstResponder()
        
        if validateCreateUserFields(email, password: password) {
            
            if let userEmail = email.text {
                if let userPassword = password.text {
                    userSignInWithEmailAndPassword(userEmail, password: userPassword)
                } else {
                    print("Create Button Error - Please Enter A Password")
                }
            } else {
                print("Create Button Error - Please Enter An Email")
            }
            
        }
        
    }
    
    @IBAction func createButtonPressed(sender: AnyObject) {
        
        email.resignFirstResponder()
        password.resignFirstResponder()
        
        if validateCreateUserFields(email, password: password) {
            
            
            if let userEmail = email.text {
                if let userPassword = password.text {
                    
                    
                    createUser(userEmail, password: userPassword)
                    
                } else {
                    print("Create Button Error - Please Enter A Password")
                }
            } else {
                print("Create Button Error - Please Enter An Email")
            }
            
            
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let email = email {
            email.delegate = self
        }
        if let password = password {
            password.delegate = self
        }
        
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        
        // MARK: Firebase Listener - 1st Step
        
        FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
            if let user = user {
                // User is signed in.
                print("User Exists - Sign In Process")
                
                self.getUserProfile()
            } else {
                // No user is signed in.
                print("User Does Not Exist")
            }
        }
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Field Validation
    func validateCreateUserFields(email: UITextField, password: UITextField) -> Bool{
        
        
        
        if email.text != nil {
            
            if password.text != nil {
                
                return true
                
            }
            
        }
        
        return false
        
    }
    
    
    // MARK: - FireBase Methods
    
    func createUser(email : String, password: String) {
        FIRAuth.auth()?.createUserWithEmail(email, password: password) { (user, error) in
            if let error = error {
                // basic usage
                self.showErrorToast(error.localizedDescription)
            } else if let user = user {
                print(user.email)
            }
        }
    }
    
    func userSignInWithEmailAndPassword(email : String, password: String) {
        FIRAuth.auth()?.signInWithEmail(email, password: password) { (user, error) in
            // ...
            if let error = error {
                // basic usage
                self.showErrorToast(error.localizedDescription)
            } else if let user = user {
                print(user.email)
            }
        }
    }
    
    func userSignInWithSocialAuth(credential : FIRAuthCredential) {
        FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
            // ...
            if let error = error {
                // basic usage
                self.showErrorToast(error.localizedDescription)
            } else if let user = user {
                print(user.displayName)
            }
        }
    }
    
    func userSignOut() {
        try! FIRAuth.auth()!.signOut()
    }
    
    // MARK: FireBase Get User Profile
    
    func getUserProfile() {
        if let user = FIRAuth.auth()?.currentUser {
            let name = user.displayName
            let email = user.email
            let photoUrl = user.photoURL
            let uid = user.uid;  // The user's ID, unique to the Firebase project.
            // Do NOT use this value to authenticate with
            // your backend server, if you have one. Use
            // getTokenWithCompletion:completion: instead.
            
            print("\(name), \(email)")
        } else {
            // No user is signed in.
            
            print("No User Profile")
        }
    }
    
    // MARK: FireBase Delete User Profile
    
    func deleteCurrentUser() {
        let user = FIRAuth.auth()?.currentUser
        
        user?.deleteWithCompletion { error in
            if let error = error {
                // An error happened.
            } else {
                // Account deleted.
            }
        }
    }
    
    // MARK: - Google Sign In Delegate Methods
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
                withError error: NSError!)
    {
        if (error == nil)
        {
            // Perform any operations on signed in user here.
            let userId = user.userID // For client-side use only!
            let idToken = user.authentication.idToken //Safe to send to the server
            let name = user.profile.name
            let email = user.profile.email
            let userImageURL = user.profile.imageURLWithDimension(200)
            // ...
            
            showErrorToast("Logged in with Google")
            let authentication = user.authentication
            let credential = FIRGoogleAuthProvider.credentialWithIDToken(authentication.idToken, accessToken: authentication.accessToken)
            
            self.userSignInWithSocialAuth(credential)
        }
        else
        {
            showErrorToast(error.localizedDescription)
        }
    }
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
                withError error: NSError!)
    {
        // Perform any operations when the user disconnects from app here.
    }
    
    
    // MARK: - UITextFieldDelegate protocol methods
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Alerts Toast
    
    func showErrorToast(message: String) {
        
        self.view.makeToast(message)
        
    }


}

