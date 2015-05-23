import UIKit

class EnterCodeViewController: UIViewController, CodeInputViewDelegate, UIAlertViewDelegate {
    var signingUp = false

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.whiteColor()

        let noticeLabel = UILabel(frame: CGRect(x: 20, y: 64, width: view.frame.width-40, height: 178))
        if signingUp {
            noticeLabel.text = "Sign Up\n\nNo user exists with the number above.\n\nTo sign up, enter the code we just sent you."
        } else {
            noticeLabel.text = "Log In\n\nA user exists with the number above.\n\nTo log in, enter the code we just sent you."
        }
        noticeLabel.textAlignment = .Center
        noticeLabel.numberOfLines = 0
        view.addSubview(noticeLabel)

        let codeInputView = CodeInputView(frame: CGRect(x: (view.frame.width-215)/2, y: 242, width: 215, height: 60))
        codeInputView.delegate = self
        codeInputView.tag = 17
        view.addSubview(codeInputView)
        codeInputView.becomeFirstResponder()
    }

    // MARK: - CodeInputViewDelegate

    func codeInputView(codeInputView: CodeInputView, didFinishWithCode code: String) {
        let activityOverlayView = ActivityOverlayView.sharedView()
        activityOverlayView.showWithTitle(signingUp ? "Verifying" : "Loging In")

        // Create cod with phone number
        if signingUp {
            var request = formRequest("POST", "/keys", ["phone": title, "code": code])
            let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                let statusCode = (response as! NSHTTPURLResponse).statusCode
                let dictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil) as! Dictionary<String, String>?

                dispatch_async(dispatch_get_main_queue(), {
                    activityOverlayView.dismissAnimated(true)

                    switch statusCode {
                    case 201:
                        let profileTableViewController = ProfileTableViewController(phone: self.title!, key: dictionary!["key"]!)
                        profileTableViewController.setEditing(true, animated: false)
                        self.navigationController?.pushViewController(profileTableViewController, animated: true)
                    default:
                        UIAlertView(dictionary: dictionary, error: error, delegate: self).show()
                        break
                    }
                })
            })
            dataTask.resume()
        } else {
            var request = formRequest("POST", "/sessions", ["phone": title, "code": code])
            let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                let statusCode = (response as! NSHTTPURLResponse).statusCode
                let dictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil) as! Dictionary<String, String>?

                dispatch_async(dispatch_get_main_queue(), {
                    activityOverlayView.dismissAnimated(true)

                    switch statusCode {
                    case 201:
                        let accessToken = dictionary!["access_token"] as String!
                        let userIDString = accessToken.substringToIndex(advance(accessToken.endIndex, -33))
                        let userID = UInt(userIDString.toInt()!)
                        account.user = User(ID: userID, username: "", firstName: "", lastName: "")
                        account.accessToken = accessToken
                    default:
                        UIAlertView(dictionary: dictionary, error: error, delegate: self).show()
                        break
                    }
                })
            })
            dataTask.resume()
        }
    }

    // MARK: - UIAlertViewDelegate

    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        (view.viewWithTag(17) as! CodeInputView).clear()
    }
}
