import UIKit

class LoadingViewController : UIViewController, UIViewControllerTransitioningDelegate {
    let fadeAnimator = FadeAnimator()

    override var title: String? {
        didSet {
            (viewIfLoaded?.viewWithTag(3) as! UILabel?)?.text = title
        }
    }

    convenience init(title: String) {
        self.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .OverFullScreen
        self.title = title
        transitioningDelegate = self
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 128, height: 128))
        containerView.autoresizingMask = [.FlexibleTopMargin, .FlexibleLeftMargin, .FlexibleBottomMargin, .FlexibleRightMargin]
        containerView.backgroundColor = UIColor(white: 0, alpha: 0.75)
        let screenBounds = UIScreen.mainScreen().bounds
        containerView.center = CGPoint(x: screenBounds.midX, y: screenBounds.midY)
        containerView.layer.cornerRadius = 10
        view.addSubview(containerView)

        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        activityIndicatorView.center = CGPoint(x: 128/2, y: 128/2)
        activityIndicatorView.startAnimating()
        containerView.addSubview(activityIndicatorView)

        let titleLabel = UILabel(frame: CGRect(x: 0, y: 128-20-16, width: 128, height: 20))
        titleLabel.font = UIFont.boldSystemFontOfSize(16)
        titleLabel.tag = 3
        titleLabel.text = title
        titleLabel.textAlignment = .Center
        titleLabel.textColor = UIColor.whiteColor()
        containerView.addSubview(titleLabel)
    }

    // MARK: - UIViewControllerTransitioningDelegate

    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        fadeAnimator.presenting = true
        return fadeAnimator
    }

    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        fadeAnimator.presenting = false
        return fadeAnimator
    }
}

class FadeAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let duration = 0.3
    var presenting = false

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return duration
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let key = presenting ? UITransitionContextToViewKey : UITransitionContextFromViewKey
        let fadingView = transitionContext.viewForKey(key)!

        if presenting {
            let containerView = transitionContext.containerView()!
            containerView.addSubview(fadingView)
            transitionContext.completeTransition(true)
        } else {
            UIView.animateWithDuration(duration, animations: { fadingView.alpha = 0 }, completion: { _ in
                transitionContext.completeTransition(true)
            })
        }
    }
}

//class ActivityOverlayView: UIView {
//    private static var myWindow: UIWindow!
//
//    var titleLabel: UILabel {
//        return self.viewWithTag(1) as! UILabel
//    }
//
//    convenience init(title: String) {
//        self.init(frame: CGRect(x: 0, y: 0, width: 128, height: 128))
//        autoresizingMask = [.FlexibleTopMargin, .FlexibleLeftMargin, .FlexibleBottomMargin, .FlexibleRightMargin]
//        backgroundColor = UIColor(white: 0, alpha: 0.75)
//        layer.cornerRadius = 10
//
//        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
//        activityIndicatorView.center = CGPoint(x: 128/2, y: 128/2)
//        activityIndicatorView.startAnimating()
//        self.addSubview(activityIndicatorView)
//
//        let titleLabel = UILabel(frame: CGRect(x: 0, y: 128-20-16, width: 128, height: 20))
//        titleLabel.font = UIFont.boldSystemFontOfSize(16)
//        titleLabel.tag = 1
//        titleLabel.text = title
//        titleLabel.textAlignment = .Center
//        titleLabel.textColor = UIColor.whiteColor()
//        self.addSubview(titleLabel)
//    }
//
//    func show() {
//        let window = UIWindow(frame: UIScreen.mainScreen().bounds)
////        let orientation = UIApplication.sharedApplication().statusBarOrientation
////        window.transform = ActivityOverlayView.transformForOrientation(orientation)
//        window.windowLevel = UIWindowLevelStatusBar
//        center = window.center
//        window.addSubview(self)
//        window.hidden = false
//        ActivityOverlayView.myWindow = window
//
//        NSNotificationCenter.defaultCenter().addObserver(ActivityOverlayView.self, selector:"didChangeStatusBarOrientationNotification:" , name: UIApplicationDidChangeStatusBarOrientationNotification, object: nil)
//
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
//            self.dismissAnimated(true)
//        }
//    }
//
//    func dismissAnimated(animated: Bool) {
//        UIView.animateWithDuration(animated ? 0.3 : 0, animations: { self.alpha = 0 }) { _ in
//            ActivityOverlayView.myWindow = nil
//            NSNotificationCenter.defaultCenter().removeObserver(ActivityOverlayView.self)
//        }
//    }
//
//    class func didChangeStatusBarOrientationNotification(notification: NSNotification) {
//        let orientation = UIApplication.sharedApplication().statusBarOrientation
//        print(orientation.rawValue)
//        myWindow.transform = transformForOrientation(orientation)
//        UIApplication.sharedApplication().statusBarHidden = UIInterfaceOrientationIsLandscape(orientation)
//    }
//
//    class func transformForOrientation(orientation: UIInterfaceOrientation) -> CGAffineTransform {
//        switch orientation {
//        case .LandscapeLeft:
//            return CGAffineTransformMakeRotation(CGFloat(-90 * M_PI / 180))
//        case .LandscapeRight:
//            return CGAffineTransformMakeRotation(CGFloat(90 * M_PI / 180))
//        default:
//            return CGAffineTransformMakeRotation(0)
//        }
//    }
//}
