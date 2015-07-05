import UIKit

class ActivityView: UIView {
    private var activityIndicatorView: UIActivityIndicatorView {
        return self.viewWithTag(1) as! UIActivityIndicatorView
    }

    var titleLabel: UILabel {
        return self.viewWithTag(2) as! UILabel
    }

    convenience init() {
        self.init(title: "Loading…")
    }

    init(title: String) {
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        let width1 = activityIndicatorView.frame.width
        activityIndicatorView.center = CGPoint(x: width1/2, y: width1/2)
        activityIndicatorView.tag = 1
        activityIndicatorView.userInteractionEnabled = false

        let titleLabel = UILabel(frame: CGRectZero)
        titleLabel.font = UIFont.systemFontOfSize(14)
        titleLabel.tag = 2
        titleLabel.text = title
        titleLabel.textAlignment = .Center
        titleLabel.textColor = UIColor(white: 102/255, alpha: 1)
        titleLabel.userInteractionEnabled = false

        super.init(frame: CGRectZero)
        self.userInteractionEnabled = false

        self.addSubview(activityIndicatorView)
        self.addSubview(titleLabel)

        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        titleLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.addConstraints([
            NSLayoutConstraint(item: self, attribute: .Trailing, relatedBy: .Equal, toItem: titleLabel, attribute: .Trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: activityIndicatorView, attribute: .Height, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: titleLabel, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: width1+4),
            NSLayoutConstraint(item: titleLabel, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: titleLabel, attribute: .Height, relatedBy: .Equal, toItem: activityIndicatorView, attribute: .Height, multiplier: 1, constant: -1)
        ])
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showInViewController(viewController: UIViewController) {
        activityIndicatorView.startAnimating()

        let view = viewController.view
        view.addSubview(self)
        view.addConstraints([
            NSLayoutConstraint(item: self, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: viewController.topLayoutGuide.length)
        ])
    }

    func dismissAnimated(animated: Bool) {
        UIView.animateWithDuration(animated ? 0.3 : 0, animations: {
            self.alpha = 0 // fade
        }, completion: { (finished) -> Void in
            self.activityIndicatorView.stopAnimating()
            self.removeFromSuperview()
        })
    }
}
