import UIKit

class WelcomeViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.orangeColor()

        let logoLabel = UILabel(frame: CGRect(x: 0, y: 64, width: view.frame.width, height: 60))
        logoLabel.autoresizingMask = .FlexibleWidth
        logoLabel.font = UIFont.boldSystemFontOfSize(72)
        logoLabel.text = "Chats"
        logoLabel.textAlignment = .Center
        logoLabel.textColor = UIColor.whiteColor()
        view.addSubview(logoLabel)

        let taglineLabel = UILabel(frame: CGRect(x: 0, y: 144, width: view.frame.width, height: 30))
        taglineLabel.autoresizingMask = .FlexibleWidth
        taglineLabel.font = UIFont.boldSystemFontOfSize(24)
        taglineLabel.text = "Chat with Friends"
        taglineLabel.textAlignment = .Center
        taglineLabel.textColor = UIColor.whiteColor()
        view.addSubview(taglineLabel)

        let continueAsGuestButton = UIButton.buttonWithType(.Custom) as! UIButton
        continueAsGuestButton.frame = CGRect(x: (view.frame.width-210)/2, y: view.frame.height-188, width: 210, height: 60)
        continueAsGuestButton.autoresizingMask = .FlexibleLeftMargin | .FlexibleRightMargin | .FlexibleTopMargin
        continueAsGuestButton.titleLabel?.font = UIFont.boldSystemFontOfSize(18)
        continueAsGuestButton.setTitle("Continue as Guest", forState: .Normal)
        continueAsGuestButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        continueAsGuestButton.setTitleColor(UIColor.darkGrayColor(), forState: .Highlighted)
        continueAsGuestButton.addTarget(self, action: "continueAsGuestAction", forControlEvents: .TouchUpInside)
        view.addSubview(continueAsGuestButton)

        let signUpButton = UIButton.buttonWithType(.Custom) as! UIButton
        signUpButton.autoresizingMask = .FlexibleTopMargin | .FlexibleWidth
        signUpButton.setBackgroundColor(UIColor.purpleColor(), forState: .Normal)
        signUpButton.frame = CGRect(x: 0, y: view.frame.height-128, width: view.frame.width, height: 64)
        signUpButton.titleLabel?.font = UIFont.boldSystemFontOfSize(32)
        signUpButton.setTitle("Sign Up", forState: .Normal)
        signUpButton.addTarget(self, action: "signUpLogInAction:", forControlEvents: .TouchUpInside)
        view.addSubview(signUpButton)

        let logInButton = UIButton.buttonWithType(.Custom) as! UIButton
        logInButton.tag = 1
        logInButton.autoresizingMask = .FlexibleTopMargin | .FlexibleWidth
        logInButton.setBackgroundColor(UIColor.blueColor(), forState: .Normal)
        logInButton.frame = CGRect(x: 0, y: view.frame.height-64, width: view.frame.width, height: 64)
        logInButton.titleLabel?.font = UIFont.boldSystemFontOfSize(32)
        logInButton.setTitle("Log In", forState: .Normal)
        logInButton.addTarget(self, action: "signUpLogInAction:", forControlEvents: .TouchUpInside)
        view.addSubview(logInButton)
    }

    func continueAsGuestAction() {
        continueAsGuest()
        view.window?.rootViewController = createTabBarController()
    }

    func signUpLogInAction(barButtonItem: UIButton) {
        let tableViewController = barButtonItem.tag == 0 ? SignUpTableViewController() : SignUpTableViewController()
        tableViewController.title = barButtonItem.titleLabel?.text
        let navigationController = UINavigationController(rootViewController: tableViewController)
        presentViewController(navigationController, animated: true, completion: nil)
    }
}
