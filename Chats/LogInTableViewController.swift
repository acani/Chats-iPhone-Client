import UIKit

class LogInTableViewController: UITableViewController, UITextFieldDelegate {
    convenience init() {
        self.init(style: .Grouped)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelAction")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "doneAction")
        title = "Log In"
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(TextFieldTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(TextFieldTableViewCell))
    }

    // MARK: - UITableView

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(TextFieldTableViewCell), forIndexPath: indexPath) as! TextFieldTableViewCell
        let textField = cell.textField
        textField.delegate = self
        textField.autocapitalizationType = .None
        textField.autocorrectionType = .No
        textField.clearButtonMode = .WhileEditing
        textField.keyboardType = .EmailAddress
        textField.placeholder = "Email"
        textField.returnKeyType = .Done
        textField.becomeFirstResponder()
        return cell
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        doneAction()
        return true
    }

    // MARK: - Actions

    func cancelAction() {
        tableView.textFieldForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))?.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
    }

    func doneAction() {
        let email = tableView.textFieldForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!.text!
            .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())

        // Validate email
        if let errorMessage = Validation.errorMessageWithEmail(email) {
            let alert = UIAlertController(title: "", message: errorMessage, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
            return
        }

        // Create code with email
        let loadingViewController = LoadingViewController(title: "Connecting")
        presentViewController(loadingViewController, animated: true, completion: nil)

        let request = api.formRequest("POST", "/login", ["email": email])
        let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            if response != nil {
                let statusCode = (response as! NSHTTPURLResponse).statusCode

                dispatch_async(dispatch_get_main_queue(), {
                    self.dismissViewControllerAnimated(true, completion: {
                        switch statusCode {
                        case 200:
                            let enterCodeViewController = EnterCodeViewController(email: email)
                            enterCodeViewController.method = .LogIn
                            self.navigationController?.pushViewController(enterCodeViewController, animated: true)
                        default:
                            let dictionary = (try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0))) as! Dictionary<String, String>?
                            let alert = UIAlertController(dictionary: dictionary, error: error, handler: nil)
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                    })
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.dismissViewControllerAnimated(true, completion: {
                        let alert = UIAlertController(dictionary: nil, error: error, handler: nil)
                        self.presentViewController(alert, animated: true, completion: nil)
                    })
                })
            }
        })
        dataTask.resume()
    }
}
