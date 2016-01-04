import UIKit

class SignUpTableViewController: UITableViewController, UITextFieldDelegate {
    var firstName = ""
    var lastName = ""
    var email = ""
    var viewIsEditing = false

    convenience init() {
        self.init(style: .Grouped)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelAction")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "doneAction")
        title = "Sign Up"
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(TextFieldTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(TextFieldTableViewCell))

        let height: CGFloat = 51 // 2-lines tall
        let tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: height))
        tableFooterView.autoresizingMask = .FlexibleWidth
        tableView.tableFooterView = tableFooterView
        tableView.sectionFooterHeight = 8

        let width = view.frame.width - 24
        let termsAndPrivacyLabel = UITextView(frame: CGRect(x: 24/2, y: 0, width: width, height: height))
        let string = "By signing up, you agree to the Terms of Use & Privacy Policy."
        let text = NSMutableAttributedString(string: string, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(11.6)])
        text.addAttribute(NSLinkAttributeName, value: "https://github.com/site/terms", range: NSMakeRange(32, 12))
        text.addAttribute(NSLinkAttributeName, value: "https://github.com/site/privacy", range: NSMakeRange(47, 14))
        termsAndPrivacyLabel.attributedText = text
        termsAndPrivacyLabel.autoresizingMask = .FlexibleWidth
        termsAndPrivacyLabel.backgroundColor = UIColor.clearColor()
        termsAndPrivacyLabel.contentInset.top = 3 // shows the top dot of text-selector bar
        termsAndPrivacyLabel.editable = false
        termsAndPrivacyLabel.scrollEnabled = false
        tableFooterView.addSubview(termsAndPrivacyLabel)
    }

    // MARK: - UITableView

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(TextFieldTableViewCell), forIndexPath: indexPath) as! TextFieldTableViewCell
        let textField = cell.textField
        textField.addTarget(self, action: "textFieldDidChange:", forControlEvents: .EditingChanged)
        textField.delegate = self

        func configureTextFieldForName() {
            textField.autocapitalizationType = .Words
            textField.keyboardType = .Default
            textField.returnKeyType = .Next
        }

        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                configureTextFieldForName()
                textField.placeholder = "First Name"
                textField.tag = 0
                textField.text = firstName
            default:
                configureTextFieldForName()
                textField.placeholder = "Last Name"
                textField.tag = 1
                textField.text = lastName
            }
        default:
            textField.autocapitalizationType = .None
            textField.keyboardType = .EmailAddress
            textField.placeholder = "Email"
            textField.returnKeyType = .Done
            textField.tag = 2
            textField.text = email
        }

        textField.autocorrectionType = .No
        textField.clearButtonMode = .WhileEditing

        if !viewIsEditing {
            textField.becomeFirstResponder()
            viewIsEditing = true
        }

        return cell
    }

    // MARK: - UITextFieldDelegate

    func textFieldDidChange(textField: UITextField) {
        switch textField.tag {
        case 0:
            firstName = textField.text!
        case 1:
            lastName = textField.text!
        default:
            email = textField.text!
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField.tag {
        case 0:
            tableView.textFieldForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))?.becomeFirstResponder()
        case 1:
            tableView.textFieldForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1))?.becomeFirstResponder()
        default:
            doneAction()
        }
        return true
    }

    // MARK: - Actions

    func cancelAction() {
        view.endEditing(false)
        dismissViewControllerAnimated(true, completion: nil)
    }

    func doneAction() {
        firstName.strip()
        lastName.strip()
        email.strip()

        // Validate parameters
        if let errorMessage = ValidationHelper.errorMessageWithFirstName(firstName, lastName: lastName, email: email) {
            let alert = UIAlertController(title: "", message: errorMessage, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Is your email correct?", message: email, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { _ in
                self.createSignupCode()
            }))
            presentViewController(alert, animated: true, completion: nil)
        }
    }

    func createSignupCode() {
        let loadingViewController = LoadingViewController(title: "Connecting")
        presentViewController(loadingViewController, animated: true, completion: nil)

        let fields = ["first_name": firstName, "last_name": lastName, "email": email]
        let request = api.formRequest("POST", "/signup", fields)
        let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            if response != nil {
                let statusCode = (response as! NSHTTPURLResponse).statusCode
                var enterCodeViewController: EnterCodeViewController!
                var dictionary: Dictionary<String, String>?

                if statusCode == 200 {
                    enterCodeViewController = EnterCodeViewController(email: self.email)
                    enterCodeViewController.method = .SignUp
                } else { // error
                    dictionary = (try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0))) as! Dictionary<String, String>?
                }

                dispatch_async(dispatch_get_main_queue(), {
                    self.dismissViewControllerAnimated(true, completion: {
                        if (enterCodeViewController != nil) {
                            self.navigationController?.pushViewController(enterCodeViewController, animated: true)
                        } else { // error
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
