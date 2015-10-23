//
//  SurveyViewController.swift
//  Mankato Kiosk
//
//  Created by John Boucha on 10/3/15.
//  Copyright © 2015 John Boucha. All rights reserved.
//


import UIKit
import CoreData

class SurveyViewController: UIViewController, UIScrollViewDelegate, PassTouchesScrollViewDelegate {
    
    var survey = [NSManagedObject]()
    
    var scrollView: CustomScrollView!
    
    var arrayOfInputs:[AnyObject] = []
    
    var timer = NSTimer()
    
    var noQuestionslabel = UILabel()
    
    var button = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor();
        
        self.arrayOfInputs = []
        
        noQuestionslabel = UILabel(frame: CGRectMake(0, view.bounds.height/2, view.bounds.width, 50))
        //
        // start timer
        //
        
        restartTimer()
        
        //
        // Create scrollview
        //
        
        scrollView = CustomScrollView(frame: view.bounds)
        scrollView.backgroundColor = UIColor(red: 254.0/255, green: 249.0/255, blue: 237.0/255, alpha: 1.0)
        scrollView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height*2)
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        scrollView.addGestureRecognizer(tap)
        
        scrollView.delegate = self
        scrollView.delegatePass = self
        
        view.addSubview(scrollView)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "adjustForKeyboard:", name: UIKeyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: "adjustForKeyboard:", name: UIKeyboardWillChangeFrameNotification, object: nil)

    }
    
    override func viewWillDisappear(animated: Bool) {
        self.arrayOfInputs = []
        
        super.viewWillDisappear(true)
    }
    
    //Calls this function when the tap is recognized.
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
        
        
    }
    

    
    func adjustForKeyboard(notification: NSNotification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let keyboardViewEndFrame = view.convertRect(keyboardScreenEndFrame, fromView: view.window)
        
        if notification.name == UIKeyboardWillHideNotification {
            self.scrollView.contentInset = UIEdgeInsetsZero
        } else {
            self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        self.scrollView.scrollIndicatorInsets = self.scrollView.contentInset
        

    }

    


    
    override func viewWillAppear(animated: Bool) {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        let hasQuestions = defaults.boolForKey("QuestionsAvailable")
        if (hasQuestions) {
            // load survey info
            self.loadSurvey()
        } else {
            // load no survey info
            self.loadNoSurvey()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func adminCheck(sender: AnyObject) {
        
        timer.invalidate()
        
        let alertController = UIAlertController(title: "Admin Settings", message: "Please input password to continue:", preferredStyle: .Alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .Default) { (_) in
            
            
            
            if let field = alertController.textFields![0] as? UITextField {
                // check password
                if (field.text == "8041") {
                    // password is good
                    
                    
                    self.performSegueWithIdentifier("adminSegue", sender:self)

                } else {
                    // password failed
                    print("fail")
                    //self.restartTimer()
                }
                
            } else {
                // user did not fill field
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in
        
            self.restartTimer()
        }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "enter password"
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func loadNoSurvey() {
        
        noQuestionslabel.textAlignment = NSTextAlignment.Center
        noQuestionslabel.text = "Sorry, questions have not been downloaded yet."
        noQuestionslabel.font = UIFont(name: "Montserrat", size: 24)
        noQuestionslabel.textColor = UIColor(red: 44.0/255, green: 62.0/255, blue: 80.0/255, alpha: 1.0)
        noQuestionslabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        noQuestionslabel.numberOfLines = 0
        
        view.addSubview(noQuestionslabel)
    }
    
    
    func loadSurvey() {
        
        noQuestionslabel.removeFromSuperview()
        
        
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Survey")
        
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            survey = results as! [NSManagedObject]
            
            print("Survey length: \(survey.count)")
            
            var heightCounter:CGFloat = 100
            
            for result in survey {
                //print(result.valueForKey("question")!)
                
                let label = UILabel(frame: CGRectMake(150, heightCounter, scrollView.bounds.width - 300, 45))
                //label.center = CGPointMake(30, heightCounter)
                
                label.textAlignment = NSTextAlignment.Left
                let tempString = result.valueForKey("question") as! String
                label.text = tempString
                label.font = UIFont(name: "Montserrat", size: 24)
                label.textColor = UIColor(red: 44.0/255, green: 62.0/255, blue: 80.0/255, alpha: 1.0)
                label.lineBreakMode = NSLineBreakMode.ByWordWrapping
                label.numberOfLines = 0
                label.sizeToFit()
                
                
                self.scrollView.addSubview(label)
                heightCounter += label.bounds.height + 20
                
                
                if result.valueForKey("questionType") as! String == "static-text" {
                    let textLabel = UILabel(frame: CGRectMake(150, heightCounter, self.scrollView.bounds.width - 300, 60))
                    textLabel.textAlignment = NSTextAlignment.Left
                    textLabel.font = UIFont(name: "Montserrat", size: 18)
                    textLabel.textColor = UIColor(red: 44.0/255, green: 62.0/255, blue: 80.0/255, alpha: 1.0)

                    
                    var myText = result.valueForKey("content") as! String
                    myText = myText.stringByReplacingOccurrencesOfString("<p>", withString: "")
                    myText = myText.stringByReplacingOccurrencesOfString("</p>", withString: "")
                    textLabel.text = myText
                    
                    textLabel.numberOfLines = 1;
                    textLabel.sizeToFit()
                    
                    
                    self.scrollView.addSubview(textLabel)
                    
                    heightCounter += textLabel.bounds.height + 20
                    
                } else if result.valueForKey("questionType") as! String == "text-input" {
                    let myTextField: UITextField = UITextField(frame: CGRectMake(150, heightCounter, self.scrollView.bounds.width - 300, 50))
                    myTextField.backgroundColor = UIColor.whiteColor()
                    myTextField.borderStyle = UITextBorderStyle.Line

                    myTextField.layer.borderColor = UIColor(red: 44.0/255, green: 62.0/255, blue: 80.0/255, alpha: 1.0).CGColor
                    myTextField.font = UIFont(name: "Helvetica", size: CGFloat(22.0) )
                    
                    self.arrayOfInputs.append(myTextField)
                    self.scrollView.addSubview(myTextField)
                    heightCounter += 100
                    
                } else if result.valueForKey("questionType") as! String == "text-area" {
                    let textView = UITextView(frame: CGRectMake(150.0, heightCounter, self.scrollView.bounds.width - 300, 100))
                    textView.textAlignment = NSTextAlignment.Left
                    textView.textColor = UIColor.blackColor()
                    textView.backgroundColor = UIColor.whiteColor()
                    textView.layer.borderWidth = 1
                    textView.layer.borderColor = UIColor(red: 44.0/255, green: 62.0/255, blue: 80.0/255, alpha: 1.0).CGColor
                    textView.font = UIFont(name: "Helvetica", size: CGFloat(22.0) )
                    
                    
                    self.scrollView.addSubview(textView)
                    self.arrayOfInputs.append(textView)
                    heightCounter += 150
                    
                } else if result.valueForKey("questionType") as! String == "numerical-input" {
                    let myNumField: UITextField = UITextField(frame: CGRectMake(150, heightCounter, self.scrollView.bounds.width - 300, 50))
                    myNumField.backgroundColor = UIColor.whiteColor()
                    myNumField.borderStyle = UITextBorderStyle.Line
                    myNumField.userInteractionEnabled = true
                    
                    self.arrayOfInputs.append(myNumField)
                    self.scrollView.addSubview(myNumField)
                    heightCounter += 100
                    
                } else if result.valueForKey("questionType") as! String == "rating" {
                    
                    // Button code from: https://github.com/shamasshahid/SSRadioButtonsController
                    
                    let button1   = SSRadioButton(type: UIButtonType.System) as UIButton
                    button1.frame = CGRectMake(70, heightCounter, 150, 60)
                    button1.setTitle("Very Low", forState: UIControlState.Normal)
                    button1.titleLabel?.font = UIFont(name: "Montserrat", size: 18)
                    
                    
                    
                    let button2   = SSRadioButton(type: UIButtonType.System) as UIButton
                    button2.frame = CGRectMake(220, heightCounter, 150, 60)
                    button2.setTitle("Low", forState: UIControlState.Normal)
                    button2.titleLabel?.font = UIFont(name: "Montserrat", size: 18)
                    button2.titleLabel?.textAlignment = .Left
                    
                    
                    let button3   = SSRadioButton(type: UIButtonType.System) as UIButton
                    button3.frame = CGRectMake(395, heightCounter, 150, 60)
                    button3.setTitle("Moderate", forState: UIControlState.Normal)
                    button3.titleLabel?.font = UIFont(name: "Montserrat", size: 18)
                    
                    
                    let button4   = SSRadioButton(type: UIButtonType.System) as UIButton
                    button4.frame = CGRectMake(570, heightCounter, 150, 60)
                    button4.setTitle("High", forState: UIControlState.Normal)
                    button4.titleLabel?.font = UIFont(name: "Montserrat", size: 18)
                    
                    
                    let button5   = SSRadioButton(type: UIButtonType.System) as UIButton
                    button5.frame = CGRectMake(745, heightCounter, 150, 60)
                    button5.setTitle("Very High", forState: UIControlState.Normal)
                    button5.titleLabel?.font = UIFont(name: "Montserrat", size: 18)
                   
                    
                    let radioButtonController = SSRadioButtonsController(buttons: button1, button2, button3, button4, button5)
                    
                    arrayOfInputs.append(radioButtonController)
                    
                    self.scrollView.addSubview(button1)
                    self.scrollView.addSubview(button2)
                    self.scrollView.addSubview(button3)
                    self.scrollView.addSubview(button4)
                    self.scrollView.addSubview(button5)
                    
                    heightCounter += 80
                }
                
                
            }
            
            heightCounter += 20
            
            button   = UIButton(type:UIButtonType.Custom) as UIButton
            button.frame = CGRectMake(self.scrollView.bounds.width/2 - 127, heightCounter, 254, 78)
            //button.backgroundColor = UIColor(red: 24.0/255, green: 188.0/255, blue: 156.0/255, alpha: 1.0)
            
            button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            //button.setTitle("Submit", forState: UIControlState.Normal)
            button.addTarget(self, action: "submitSurvey:", forControlEvents: UIControlEvents.TouchUpInside)
            button.titleLabel!.font = UIFont(name: "Montserrat", size: 20)
            button.userInteractionEnabled = true
            
            let image = UIImage(named: "Submit Button")
            
            button.setImage(image, forState: .Normal)
            
            self.scrollView.addSubview(button)
            heightCounter += 120
            
            self.scrollView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.width, heightCounter+30)
            
            //print("end loading question survey")
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func submitSurvey(sender:UIButton!)
    {
        var answerString = ""
        
        print("Input number: \(arrayOfInputs.count)")
        
        for object in arrayOfInputs {
            
            
            if object is UITextField {
                let tmpObject = object as! UITextField
                var tempString = tmpObject.text!
                tempString = tempString.stringByReplacingOccurrencesOfString(",", withString: " ")
                if tempString.characters.count > 1 {
                    tempString += ","
                } else {
                    tempString = ","
                }
                answerString += tempString
                
            } else if object is UITextView {
                let tmpObject = object as! UITextView
                var tempString = tmpObject.text
                tempString = tempString.stringByReplacingOccurrencesOfString(",", withString: " ")
                if tempString.characters.count > 1 {
                    tempString! += ","
                }else {
                    tempString = ","
                }
                answerString += tempString
                
            } else if object is SSRadioButtonsController {
                let tmpObject = object as! SSRadioButtonsController
                if let tmpString = tmpObject.selectedButton()?.titleLabel?.text! {
                    answerString += "\(tmpString),"
                    print("found button")
                } else {
                    answerString += ","
                    print("button fail")
                }
            }
        }
        
        // Remove last ',' if it exists in answerString
        var lastChar = Array(arrayLiteral: answerString)[0]
        lastChar = answerString.substringFromIndex(answerString.endIndex.advancedBy(-1))
        if lastChar == "," {
            //answerString.removeAtIndex(answerString.endIndex.advancedBy(-1))
        }
        
        let numOfOccurences = answerString.componentsSeparatedByString(",").count - 1
        
        
        var answers = [NSManagedObject]()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entity =  NSEntityDescription.entityForName("Answers", inManagedObjectContext:managedContext)
        
        let answersToSave = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        answersToSave.setValue(answerString, forKey: "answers")
        
        let answerDate = NSDate()
        answersToSave.setValue(answerDate, forKey: "dateSubmitted")
        
        do {
            try managedContext.save()
            
            answers.append(answersToSave)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
        
        // Alert user on success
        let alertController = UIAlertController(title: "Thanks!", message:
            "Your submission has been saved.", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
            
            
            for object in self.arrayOfInputs {
                if object is UITextField {
                    //object.text = ""
                    let tmpObject = object as! UITextField
                    tmpObject.text = ""
                    
                } else if object is UITextView {
                    let tmpObject = object as! UITextView
                    tmpObject.text = ""
                    
                } else if object is SSRadioButtonsController {
                    let tmpObject = object as! SSRadioButtonsController
                    
                    // if button is selected, deselect it
                    if let tmpButton = tmpObject.selectedButton() as! SSRadioButton! {
                        
                        tmpButton.selected = false
                        
                        // print("should work?")
                    } else {
                        // print("failed to assign button")
                    }
                    
                    
                    
                } else {
                    // print("failed to create button controller")
                }
                
                
            }
            
            self.navigationController?.popToRootViewControllerAnimated(true)
            
        }))
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
        // Delay the dismissal by 15 seconds
        let delay = 15.0 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            alertController.dismissViewControllerAnimated(true, completion: { () -> Void in
                // do nothing
                for object in self.arrayOfInputs {
                    if object is UITextField {
                        //object.text = ""
                        let tmpObject = object as! UITextField
                        tmpObject.text = ""
                        
                    } else if object is UITextView {
                        let tmpObject = object as! UITextView
                        tmpObject.text = ""
                        
                    } else if object is SSRadioButtonsController {
                        let tmpObject = object as! SSRadioButtonsController
                        
                        // if button is selected, deselect it
                        if let tmpButton = tmpObject.selectedButton() as! SSRadioButton! {
                            
                            tmpButton.selected = false
                            
                            // print("should work?")
                        } else {
                            // print("failed to assign button")
                        }
                        
                        
                        
                    } else {
                        // print("failed to create button controller")
                    }
                    
                    
                }
            })
            
            self.navigationController?.popToRootViewControllerAnimated(true)
        })
        
    }
    

    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        restartTimer()
    }

    
    
    
    func autoClose() {
        
       print("closing")
        
        
        let alertController = UIAlertController(title: "Warning", message:
            "Survey will close due to inactivity. Press button to continue entering data.", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.Default,handler: { (_) in
        
            self.restartTimer()
        }))
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
        // Delay the dismissal by 15 seconds
        let delay = 15.0 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            alertController.dismissViewControllerAnimated(true, completion: { () -> Void in
                 self.submitSurvey(self.button)
            })
        })
        
 
    }
    
    func touchBegan() {
        //restartTimer()
    }
    
    func restartTimer() {
        timer.invalidate()
        
        timer = NSTimer(timeInterval: 300.0, target: self, selector: "autoClose", userInfo: nil, repeats: false)
         NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        print("timer started")
    }
    
    

    
    
    
}
