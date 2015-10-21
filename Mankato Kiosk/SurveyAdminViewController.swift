//
//  SurveyAdminViewController.swift
//  Mankato Kiosk
//
//  Created by John Boucha on 10/3/15.
//  Copyright © 2015 John Boucha. All rights reserved.
//

import UIKit
import CoreData
import MessageUI

class SurveyAdminViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    var survey = [NSManagedObject]()
    let activityIndicator = UIActivityIndicatorView()
    
    let mail = MFMailComposeViewController()
    let file = "survey.csv"
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "Survey Admin Panel"
        
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor();
        
       
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.center = self.view.center
        
        self.view.addSubview(activityIndicator)
        
        //mail.mailComposeDelegate = self
        
        /*
        //1
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        //2
        let fetchRequest = NSFetchRequest(entityName: "Survey")
        
        //3
        do {
            let results =
            try managedContext.executeFetchRequest(fetchRequest)
            survey = results as! [NSManagedObject]
            for result in survey {
                print(result.valueForKey("question")!)
            }
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }*/
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func getSurveyQuestions(sender: AnyObject) {
        
        let refreshAlert = UIAlertController(title: "Warning", message: "Existing questions and answers will be removed upon new database sync. Coninue?", preferredStyle: UIAlertControllerStyle.Alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
            let session = NSURLSession.sharedSession()
            let urlString = "http://quiz.aginspire.org/wp-json/posts?type=survey-questions&filter[posts_per_page]=99&filter[order]=ASC"
            let url = NSURL(string: urlString)
            let request = NSURLRequest(URL: url!)
            let dataTask = session.dataTaskWithRequest(request) { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                //print("done, error: \(error)")
                //print(" ")
                //print(data)
                self.processJSON(data!)
                
            }
            
            self.activityIndicator.startAnimating()
            dataTask.resume()
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
            // do nothing
        }))
        
        presentViewController(refreshAlert, animated: true, completion: nil)
        
        
        
        
    }
    
    func processJSON(data: NSData) {
        let json = JSON(data: data)
        
        
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        
        // Remove Old Questions
        
        let fetchRequest = NSFetchRequest(entityName: "Survey")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try managedContext.executeRequest(deleteRequest)
        } catch let error as NSError {
            // TODO: handle the error
            print("Failed to remove old questions")
            print(error)
        }
        
        // Remove Old Answers
        
        let answerFetchRequest = NSFetchRequest(entityName: "Answers")
        let answerDeleteRequest = NSBatchDeleteRequest(fetchRequest: answerFetchRequest)
        
        do {
            try managedContext.executeRequest(answerDeleteRequest)
        } catch let error as NSError {
            // TODO: handle the error
            print("Failed to remove old answers")
            print(error)
        }
        
        
        // Insert New Questions
        
        let entity =  NSEntityDescription.entityForName("Survey",
            inManagedObjectContext:managedContext)
        
        
        
        
        
        for var index = 0; index < json.count; ++index {
            
            //let surveyID = "1"
            
            /*print(json[index]["title"].stringValue)
            print(json[index]["content"].stringValue)
            print(json[index]["meta"]["survey_question_type"].stringValue)
            print(json[index]["meta"]["survey_question_position"].intValue)
            print(json[index]["terms"]["collections"][0]["slug"].stringValue)
            print(" ")
            */
            
            let surveyQuestion = json[index]["title"].stringValue
            let surveyContent = json[index]["content"].stringValue
            let surveyType = json[index]["meta"]["survey_question_type"].stringValue
            let surveyPosition = json[index]["meta"]["survey_question_position"].intValue
            let surveySlug = json[index]["terms"]["collections"][0]["slug"].stringValue
            
            let question = NSManagedObject(entity: entity!,
                insertIntoManagedObjectContext: managedContext)
            
            question.setValue(surveyQuestion, forKey: "question")
            question.setValue(surveyContent, forKey: "content")
            question.setValue(surveyType, forKey: "questionType")
            question.setValue(surveyPosition, forKey: "position")
            question.setValue(surveySlug, forKey: "surveySlug")
            
            do {
                try managedContext.save()
 
                survey.append(question)
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
            
        }
        
        // Set QuestionsAvailable to true in NSUserDefaults
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(true, forKey: "QuestionsAvailable")
        
        // Done with activity
        dispatch_async(dispatch_get_main_queue(), {
             self.activityIndicator.stopAnimating()
        });
        
        // Alert user on success
        let alertController = UIAlertController(title: "Success", message:
            "Survey questions have successfully been updated.", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func emailData(sender: AnyObject) {
        
        
        var questionString = ""
        
        // Get Questions
        var surveyQuestions = [NSManagedObject]()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Survey")
        
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            surveyQuestions = results as! [NSManagedObject]
            
            for result in surveyQuestions {
                
                let questionType = result.valueForKey("questionType") as! String
                if (questionType != "static-text") {
                    var tempString = result.valueForKey("question") as! String
                    tempString = "\"\(tempString)\""
                    questionString += tempString+","
                }
                
            }
            
            questionString += "Date Submitted,"
            
            // Remove last ',' if it exists in questionString
            var lastChar = Array(arrayLiteral: questionString)[0]
            lastChar = questionString.substringFromIndex(questionString.endIndex.advancedBy(-1))
            if lastChar == "," {
                questionString.removeAtIndex(questionString.endIndex.advancedBy(-1))
            }
            
            
            
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        // End Get Questions
        
        
        // Get Answers
        var answerString = ""
        var surveyAnswers = [NSManagedObject]()
        let answerFetchRequest = NSFetchRequest(entityName: "Answers")
        do {
            let results = try managedContext.executeFetchRequest(answerFetchRequest)
            surveyAnswers = results as! [NSManagedObject]
            
            for result in surveyAnswers {
                let tempString = result.valueForKey("answers") as! String
                
                //answerString.append(tempString)
                //answerString.append("\n")
                
                answerString += tempString
                
                let tempDate = result.valueForKey("dateSubmitted") as! NSDate
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                let tempDateString = dateFormatter.stringFromDate(tempDate)
                
                
                answerString += tempDateString
                
                answerString += "\n"
            }
            
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        
        // End Get Answers
        
        
        print(answerString)
        
        
        //let text = "1,2,3,4,Very Low"
        let text = "\(questionString)\n\(answerString)"
        
        
        if let dir : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            let path = dir.stringByAppendingPathComponent(file);
            
            // Write CSV to disk
            do {
                try text.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding)
            }
            catch {/* error handling here */
                print("failed to write")
            }
            
            // Send file by email
            
            let mailComposeViewController = configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.presentViewController(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }
        }
        
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        //mailComposerVC.setToRecipients(["nurdin@gmail.com"])
        mailComposerVC.setSubject("Mankato Museum Survey Data")
        mailComposerVC.setMessageBody("Attached is the survey data from the Ag Inspire kiosk as a .csv file.", isHTML: false)
        
        // Add .CSV attachement
        
        
        if let dir : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            print("File Directory loaded.")
            
            let path = dir.stringByAppendingPathComponent(file);
            
            if let fileData = NSData(contentsOfFile: path) {
                print("File data loaded.")
                mailComposerVC.addAttachmentData(fileData, mimeType: "text/csv", fileName: "survey-data")
            } else {
                print("File data FAIL")
            }
        } else {
            print("File path FAIL")
        }
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        
    }


}
