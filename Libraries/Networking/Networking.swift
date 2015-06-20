import UIKit

func URLWithPath(path: String) -> NSURL {
    return NSURL(string: path, relativeToURL: baseURL)!
}

// Convert ["name1": "value1", "name2": "value2"] to "name1=value1&name2=value2".
// NOTE: Like curl, let end-users URL encode names & values.
func HTTPBodyFromParameters(parameters: Dictionary<String, String>) -> String {
    var data = [String]()
    for (name, value) in parameters {
        data.append("\(name)=\(value)")
    }
    return join("&", data)
}

func formRequest(HTTPMethod: String, path: String, parameters: Dictionary<String, String>) -> NSMutableURLRequest {
    let request = NSMutableURLRequest(URL: URLWithPath(path))
    request.HTTPMethod = HTTPMethod
    request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    request.HTTPBody = HTTPBodyFromParameters(parameters).dataUsingEncoding(NSUTF8StringEncoding)
    return request
}

func multipartRequest(path: String, data: NSData, parameters: Dictionary<String, String>) -> NSMutableURLRequest {
    let request = NSMutableURLRequest(URL: URLWithPath(path))
    request.HTTPMethod = "POST"

    let boundary = "-----AcaniFormBoundary" + randomStringWithLength(16)
    request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

    var bodyString = ""
    for (name, value) in parameters {
        bodyString += "--" + boundary + "\r\n"
        bodyString += "Content-Disposition: form-data; name=\"\(name)\"" + "\r\n" + "\r\n"
        bodyString += value + "\r\n"
    }
    bodyString += "--" + boundary + "\r\n"
    var name = "file"
    bodyString += "Content-Disposition: form-data; name=\"\(name)\"" + "; filename=\"p.jpg\"" + "\r\n"
    bodyString += "Content-Type: image/jpeg" + "\r\n" + "\r\n"
    var body = NSMutableData(data: bodyString.dataUsingEncoding(NSUTF8StringEncoding)!)
    body.appendData(data)
    bodyString = "\r\n" + "--" + boundary + "--" + "\r\n"
    body.appendData(bodyString.dataUsingEncoding(NSUTF8StringEncoding)!)
    request.HTTPBody = body

    return request
}

func randomStringWithLength(length: Int) -> String {
    let alphabet = "-_1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    return String((0..<length).map { _ -> Character in
        return alphabet[advance(alphabet.startIndex, Int(arc4random_uniform(64)))]
    })
}

extension String {
    // Percent encode all characters except alphanumerics, "*", "-", ".", and "_". Replace " " with "+".
    // http://www.w3.org/TR/html5/forms.html#application/x-www-form-urlencoded-encoding-algorithm
    func stringByAddingFormURLEncoding() -> String {
        let characterSet = NSMutableCharacterSet.alphanumericCharacterSet()
        characterSet.addCharactersInString("*-._ ")
        return stringByAddingPercentEncodingWithAllowedCharacters(characterSet)!.stringByReplacingOccurrencesOfString(" ", withString: "+")
    }
}

extension UIAlertView {
    convenience init(dictionary: Dictionary<String, String>?, error: NSError!, delegate: AnyObject?) {
        let title = dictionary?["title"] ?? "Error"
        let message = dictionary?["message"] ?? (error != nil ? error.localizedDescription : "Could not connect to server.")
        self.init(title: title, message: message, delegate: delegate, cancelButtonTitle: "OK")
    }
}
