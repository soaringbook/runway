//
//  LoginViewController.swift
//  Runway
//
//  Created by Jelle Vandenbeeck on 29/09/15.
//  Copyright © 2015 Soaring Book. All rights reserved.
//

import UIKit

class LoginViewController : UIViewController, UITextFieldDelegate {
    var loginView: LoginView! { return self.view as! LoginView }
    
    let slideTransitionDelegate = SlideTransitioningDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillShowNotification, object: nil, queue: NSOperationQueue.mainQueue()) { notification in
            self.loginView.handleKeyboardNotification(notification)
        }
        NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillHideNotification, object: nil, queue: NSOperationQueue.mainQueue()) { notification in
            self.loginView.handleKeyboardNotification(notification)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    
        dispatch_main_after(1.0) {
            if SBKeychain.sharedInstance.token == nil {
                self.loginView.animateIn()
            } else {
                self.presentCorrectFlow()
            }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        loginView.reset()
    }
    
    // MARK: - Gestures
    
    @IBAction func tap(sender: AnyObject) {
        loginView.resignFirstResponder()
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        authenticate(textField: textField)
        return true
    }
    
    // MARK: - Service
    
    private func authenticate(textField textField: UITextField) {
        loginView.resignFirstResponder()
        loginView.startAnimating()
        SBWebService().authenticate(token: textField.text ?? "") { response in
            dispatch_main {
                if let error = response.error {
                    self.navigationController?.presentErrorController(error)
                    self.loginView.stopAnimating()
                } else {
                    textField.resignFirstResponder()
                    self.presentCorrectFlow()
                }
            }
        }
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        segue.destinationViewController.transitioningDelegate = slideTransitionDelegate
    }
    
    // MARK: - Navigation
    
    private func presentCorrectFlow() {
        performSegueWithIdentifier("Application", sender: nil)
    }
}