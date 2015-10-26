import UIKit

class EnterEmailTableViewController: UITableViewController {
    convenience init() {
        self.init(style: .Grouped)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Verify", style: .Done, target: self, action: "verifyAction")
        title = "Enter Email"
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(TextFieldTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(TextFieldTableViewCell))

        let tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44+32))
        tableFooterView.autoresizingMask = .FlexibleWidth
        tableView.tableFooterView = tableFooterView

        let continueAsGuestButton = UIButton(type: .System)
        continueAsGuestButton.addTarget(self, action: "continueAsGuestAction", forControlEvents: .TouchUpInside)
        continueAsGuestButton.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleTopMargin]
        continueAsGuestButton.frame = CGRect(x: (view.frame.width-184)/2, y: 32, width: 184, height: 44)
        continueAsGuestButton.setTitle("Continue as Guest", forState: .Normal)
        continueAsGuestButton.titleLabel?.font = UIFont.systemFontOfSize(17)
        tableFooterView.addSubview(continueAsGuestButton)
    }

    // MARK: - UITableViewDataSource

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(TextFieldTableViewCell), forIndexPath: indexPath) as! TextFieldTableViewCell
        let textField = cell.textField
        textField.clearButtonMode = .WhileEditing
        textField.keyboardType = .NumberPad
        textField.placeholder = "Email"
        textField.becomeFirstResponder()
        return cell
    }

    // MARK: - Actions

    func verifyAction() {
        // Validate email
        let email = tableView.textFieldForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!.text!
            .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if isValidEmail(email) {
            let alertView = UIAlertView(title: "", message: "Phone number must be 10 digits.", delegate: nil, cancelButtonTitle: "OK")
            alertView.show()
            return
        }

        // Create code with email
        let activityOverlayView = ActivityOverlayView.sharedView()
        activityOverlayView.showWithTitle("Connecting")

        let request = api.formRequest("POST", "/codes", ["email": email])
        let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            if response != nil {
                let statusCode = (response as! NSHTTPURLResponse).statusCode

                dispatch_async(dispatch_get_main_queue(), {
                    activityOverlayView.dismissAnimated(true)

                    switch statusCode {
                    case 201, 200: // sign-up, log-in
                        let enterCodeViewController = EnterCodeViewController(nibName: nil, bundle: nil)
                        enterCodeViewController.title = email
                        enterCodeViewController.signingUp = statusCode == 201 ? true : false
                        self.navigationController?.pushViewController(enterCodeViewController, animated: true)
                    default:
                        let dictionary = (try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0))) as! Dictionary<String, String>?
                        UIAlertView(dictionary: dictionary, error: error, delegate: nil).show()
                    }
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    activityOverlayView.dismissAnimated(true)
                    UIAlertView(dictionary: nil, error: error, delegate: nil).show()

                })
            }
        })
        dataTask.resume()
    }

    func continueAsGuestAction() {
        (UIApplication.sharedApplication().delegate as! AppDelegate).continueAsGuest()
    }

    // MARK: - Helpers

    func isValidEmail(email: String) -> Bool {
        let emailCharacters = email.characters
        return 3...254 ~= emailCharacters.count && emailCharacters.contains("@")
    }
}
