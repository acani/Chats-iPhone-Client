import UIKit

class SignUpTableViewController: UITableViewController {
    convenience init() {
        self.init(style: .Grouped)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelAction")
        let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "doneAction")
        doneBarButtonItem.enabled = false
        navigationItem.rightBarButtonItem = doneBarButtonItem
    }

    // MARK - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(TextFieldTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(TextFieldTableViewCell))
    }

    // MARK: UITableViewDataSource

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(TextFieldTableViewCell), forIndexPath: indexPath) as! TextFieldTableViewCell
        let textField = cell.textField
        textField.addTarget(self, action: "textFieldDidChange:", forControlEvents: .EditingChanged)
        textField.keyboardType = UIKeyboardType.PhonePad
        textField.placeholder = "Mobile number"
        textField.becomeFirstResponder()
        return cell
    }

    // MARK: Actions

    func textFieldDidChange(textField: UITextField) {
        let textLength = count(textField.text)
        navigationItem.rightBarButtonItem?.enabled = ((10...11) ~= textLength)
    }

    func cancelAction() {
        tableView.textFieldForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))?.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
    }

    func doneAction() {
        println("Done")
//        myAccount.createCodeWithPhone(textField.text)
    }
}
