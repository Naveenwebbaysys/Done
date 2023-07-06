//
//  Utilities.swift
//  Alicorn
//
//  Created by Mac on 02/05/23.
//

import Foundation
import UIKit
import SystemConfiguration
import AuthenticationServices
import AVFoundation


let aooColor = UIColor(hex:"98C455")
var observer: NSObjectProtocol?
@IBDesignable extension UIView {
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
    @IBInspectable
        var shadowRadius: CGFloat {
            get {
                return layer.shadowRadius
            }
            set {

                layer.shadowRadius = newValue
            }
        }
        @IBInspectable
        var shadowOffset : CGSize{

            get{
                return layer.shadowOffset
            }set{

                layer.shadowOffset = newValue
            }
        }

        @IBInspectable
        var shadowColor : UIColor{
            get{
                return UIColor.init(cgColor: layer.shadowColor!)
            }
            set {
                layer.shadowColor = newValue.cgColor
            }
        }
        @IBInspectable
        var shadowOpacity : Float {

            get{
                return layer.shadowOpacity
            }
            set {

                layer.shadowOpacity = newValue

            }
        }
}



@IBDesignable extension UIButton {
    
    @IBInspectable override var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable override var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable override var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
    
    func applyGradient(colors: [CGColor])
    {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.frame = self.bounds
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    @IBDesignable
    final class GradientButton: UIButton {
        @IBInspectable var startColor: UIColor = UIColor.clear
        @IBInspectable var endColor: UIColor = UIColor.clear
        
        override func draw(_ rect: CGRect) {
            let gradient: CAGradientLayer = CAGradientLayer()
            gradient.frame = CGRect(x: CGFloat(0),
                                    y: CGFloat(0),
                                    width: superview!.frame.size.width,
                                    height: superview!.frame.size.height)
            gradient.colors = [startColor.cgColor, endColor.cgColor]
            gradient.zPosition = -1
            layer.addSublayer(gradient)
        }
    }
}




@IBDesignable class BigSwitch: UISwitch {
    
    @IBInspectable var scale : CGFloat = 1{
        didSet{
            setup()
        }
    }
    
    //from storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    //from code
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup(){
        self.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
    
    override func prepareForInterfaceBuilder() {
        setup()
        super.prepareForInterfaceBuilder()
    }
    
    
}

extension UITextField{
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
}

@IBDesignable
public class Gradient: UIView {
    @IBInspectable var startColor:   UIColor = .black { didSet { updateColors() }}
    @IBInspectable var endColor:     UIColor = .white { didSet { updateColors() }}
    @IBInspectable var startLocation: Double =   0.05 { didSet { updateLocations() }}
    @IBInspectable var endLocation:   Double =   0.95 { didSet { updateLocations() }}
    @IBInspectable var horizontalMode:  Bool =  false { didSet { updatePoints() }}
    @IBInspectable var diagonalMode:    Bool =  false { didSet { updatePoints() }}

    override public class var layerClass: AnyClass { CAGradientLayer.self }

    var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }

    func updatePoints() {
        if horizontalMode {
            gradientLayer.startPoint = diagonalMode ? .init(x: 1, y: 0) : .init(x: 0, y: 0.5)
            gradientLayer.endPoint   = diagonalMode ? .init(x: 0, y: 1) : .init(x: 1, y: 0.5)
        } else {
            gradientLayer.startPoint = diagonalMode ? .init(x: 0, y: 0) : .init(x: 0.5, y: 0)
            gradientLayer.endPoint   = diagonalMode ? .init(x: 1, y: 1) : .init(x: 0.5, y: 1)
        }
    }
    func updateLocations() {
        gradientLayer.locations = [startLocation as NSNumber, endLocation as NSNumber]
    }
    func updateColors() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    }
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updatePoints()
        updateLocations()
        updateColors()
    }

}



extension UIView {
    
    var x: CGFloat {
        get {
            self.frame.origin.x
        }
        set {
            self.frame.origin.x = newValue
        }
    }
    
    var y: CGFloat {
        get {
            self.frame.origin.y
        }
        set {
            self.frame.origin.y = newValue
        }
    }
    
    var height: CGFloat {
        get {
            self.frame.size.height
        }
        set {
            self.frame.size.height = newValue
        }
    }
    
    var headerWidth: CGFloat {
        get {
            self.frame.size.width
        }
        set {
            self.frame.size.width = newValue
        }
    }
    
    func setRoundCornersBY(corners : CACornerMask , cornerRaduis : CGFloat = 15){
        if #available(iOS 11.0, *){
            self.clipsToBounds = true
            self.layer.cornerRadius = cornerRaduis
            self.layer.maskedCorners = corners
        }
    }
}




extension UIViewController {
    //    codeNotReceivedAlert.view.tintColor = UIColor(#colorLiteral(red: 0, green: 0.8465872407, blue: 0.7545004487, alpha: 1))
    //        codeNotReceivedAlert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (action: UIAlertAction!) in
    //
    func showAlert(title: String?, message: String?, actionTitles:[String?], actions:[((UIAlertAction) -> Void)?]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        //        alert.view.tintColor = UIColor(#colorLiteral(red: 0, green: 0, blue: 0.7545004487, alpha: 1))
        for (index, title) in actionTitles.enumerated() {
            let action = UIAlertAction(title: title, style: .default, handler: actions[index])
            alert.addAction(action)
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    public func openAlert(title: String,
                          message: String,
                          alertStyle:UIAlertController.Style,
                          actionTitles:[String],
                          actionStyles:[UIAlertAction.Style],
                          actions: [((UIAlertAction) -> Void)]){
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: alertStyle)
        for(index, indexTitle) in actionTitles.enumerated(){
            let action = UIAlertAction(title: indexTitle, style: actionStyles[index], handler: actions[index])
            alertController.addAction(action)
            
        }
        self.present(alertController, animated: true)
    }
    
    
 
}

extension UIViewController
{
    func SimpleAlert(Alertmessage:String)
    {
        let Alert = UIAlertController.init(title: "Alert", message: Alertmessage , preferredStyle: .alert)
        let ok = UIAlertAction.init(title: "OK", style: .default)
        Alert.addAction(ok)
        self.present(Alert, animated: true, completion: nil)
    }
    
    func showToast(message:String)
    {
        let toastLabel = UILabel(frame: CGRect(x: 20, y: self.view.frame.height - 125, width: self.view.frame.width - 50, height: 35))
        toastLabel.backgroundColor = UIColor(named: "app_color")
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 13.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 18
        toastLabel.clipsToBounds = true
        self.view.addSubview(toastLabel)
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            UIView.animate(withDuration: 2.0, delay: 0.2, options: .curveEaseOut, animations:
                            {
                toastLabel.alpha = 0.0
                
            }) { (isCompleted) in
                toastLabel.removeFromSuperview()
            }
        }
    }
    
    func isValidEmail(testEmialString : String) -> Bool
    {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testEmialString)
    }
    
    func removeUrlFromFileManager(_ outputFileURL: URL?) {
        if let outputFileURL = outputFileURL {
            
            let path = outputFileURL.path
            if FileManager.default.fileExists(atPath: path) {
                do {
                    try FileManager.default.removeItem(atPath: path)
                    print("url SUCCESSFULLY removed: \(outputFileURL)")
                } catch {
                    print("Could not remove file at url: \(outputFileURL)")
                }
            }
        }
    }
}

class UserDetails
{
    static var userId = "UserId"
    static var userName = "userName"
    static var userMailID =  "userMailID"
    static var userPhoneNo = "userPhoneNo"
    static var newPhoneNumber = "newPhoneNumber"
    static var deptName = "deptName" 
    
}

extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
    
    static func getCurrentDate() -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy HH:mm:ss"
        return dateFormatter.string(from: Date())
    }
}

func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
    let size = image.size
    let widthRatio  = targetSize.width  / size.width
    let heightRatio = targetSize.height / size.height
    var newSize: CGSize
    if(widthRatio > heightRatio) {
        newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
    } else {
        newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
    }
    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage
}



struct Users{
    
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let identityToken: String
    
    init(credentials: ASAuthorizationAppleIDCredential) {
        self.id = credentials.user
        self.firstName = credentials.fullName?.givenName ?? ""
        self.lastName = credentials.fullName?.familyName ?? ""
        self.email = credentials.email ?? ""
        self.identityToken = String(bytes: credentials.identityToken ?? Data(), encoding: .utf8) ?? ""
    }
}
extension String {
    func isValidEmail() -> Bool {
        // here, `try!` will always succeed because the pattern is valid
        let regex = try! NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
    
    func convertToUrl() -> URL {
        let data:Data = self.data(using: String.Encoding.utf8)!
        var resultStr: String = String(data: data, encoding: String.Encoding.nonLossyASCII)!
        
        if !(resultStr.hasPrefix("itms://")) && !(resultStr.hasPrefix("file://")) && !(resultStr.hasPrefix("http://")) && !(resultStr.hasPrefix("https://")) { resultStr = "http://" + resultStr }
        
        resultStr = resultStr.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        return URL(string: resultStr)!
    }
}

extension UIImage{
    
    var roundMyImage: UIImage {
        let rect = CGRect(origin:CGPoint(x: 0, y: 0), size: self.size)
        UIGraphicsBeginImageContextWithOptions(self.size, false, 1)
        UIBezierPath(
            roundedRect: rect,
            cornerRadius: self.size.height
        ).addClip()
        self.draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    func resizeMyImage(newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    
    func squareMyImage() -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: self.size.width, height: self.size.width))
        
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.width))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
}

public class Reachability {
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        /* Only Working for WIFI
         let isReachable = flags == .reachable
         let needsConnection = flags == .connectionRequired
         
         return isReachable && !needsConnection
         */
        
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
        
    }
}

public class InternetConnectionManager {
    
    
    private init() {
        
    }
    
    public static func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                
                SCNetworkReachabilityCreateWithAddress(nil, $0)
                
            }
            
        }) else {
            
            return false
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
}



func getPointForView(_ view : UISegmentedControl) -> (x:CGFloat,y:CGFloat)
{
    let x = view.frame.origin.x
    let y = view.frame.origin.y
    return (x,y)
}


extension UISegmentedControl
{
    func defaultConfiguration(font: UIFont = UIFont.systemFont(ofSize: 12), color: UIColor = UIColor.white)
    {
        let defaultAttributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: color
        ]
        setTitleTextAttributes(defaultAttributes, for: .normal)
    }

    func selectedConfiguration(font: UIFont = UIFont.boldSystemFont(ofSize: 12), color: UIColor = UIColor.red)
    {
        let selectedAttributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: color
        ]
        setTitleTextAttributes(selectedAttributes, for: .selected)
    }
}

extension Array where Element: Equatable {

    @discardableResult mutating func remove(object: Element) -> Bool {
        if let index = firstIndex(of: object) {
            self.remove(at: index)
            return true
        }
        return false
    }

    @discardableResult mutating func remove(where predicate: (Array.Iterator.Element) -> Bool) -> Bool {
        if let index = self.firstIndex(where: { (element) -> Bool in
            return predicate(element)
        }) {
            self.remove(at: index)
            return true
        }
        return false
    }

}


extension TimeZone {
    static let gmt = TimeZone(secondsFromGMT: 0)!
}
extension Locale {
    static let ptBR = Locale(identifier: "pt_BR")
}
extension Formatter {
    static let date = DateFormatter()
}

extension Date {
    func localizedDescription(date dateStyle: DateFormatter.Style = .medium,
                              time timeStyle: DateFormatter.Style = .medium,
                              in timeZone: TimeZone = .current,
                              locale: Locale = .current,
                              using calendar: Calendar = .current) -> String {
        Formatter.date.calendar = calendar
        Formatter.date.locale = locale
        Formatter.date.timeZone = timeZone
        Formatter.date.dateStyle = dateStyle
        Formatter.date.timeStyle = timeStyle
        return Formatter.date.string(from: self)
    }
    var localizedDescription: String { localizedDescription() }
}


extension Date {

    var fullDate: String { localizedDescription(date: .full, time: .none) }
    var longDate: String { localizedDescription(date: .long, time: .none) }
    var mediumDate: String { localizedDescription(date: .medium, time: .none) }
    var shortDate: String { localizedDescription(date: .short, time: .none) }

    var fullTime: String { localizedDescription(date: .none, time: .full) }
    var longTime: String { localizedDescription(date: .none, time: .long) }
    var mediumTime: String { localizedDescription(date: .none, time: .medium) }
    var shortTime: String { localizedDescription(date: .none, time: .short) }

    var fullDateTime: String { localizedDescription(date: .full, time: .full) }
    var longDateTime: String { localizedDescription(date: .long, time: .long) }
    var mediumDateTime: String { localizedDescription(date: .medium, time: .medium) }
    var shortDateTime: String { localizedDescription(date: .short, time: .short) }
}


extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbColorValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbColorValue)
        
        let r = (rgbColorValue & 0xff0000) >> 16
        let g = (rgbColorValue & 0xff00) >> 8
        let b = rgbColorValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
    
 
}


func dateHelper (srt : String) -> String{
    let formatter = DateFormatter()
    // initially set the format based on your datepicker date / server String
    formatter.dateFormat = "yyy-MM-dd"


    let yourDate = formatter.date(from: srt)
    //then again set the date format whhich type of output you need
    formatter.dateFormat = "MMM d, yyyy"
    // again convert your date to string
    let myStringDate = formatter.string(from: yourDate!)

    print(myStringDate)
    return myStringDate
}


@IBDesignable class PaddingLabel: UILabel {

    @IBInspectable var topInset: CGFloat = 5.0
    @IBInspectable var bottomInset: CGFloat = 5.0
    @IBInspectable var leftInset: CGFloat = 7.0
    @IBInspectable var rightInset: CGFloat = 7.0

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }

    override var bounds: CGRect {
        didSet {
            // ensures this works within stack views if multi-line
            preferredMaxLayoutWidth = bounds.width - (leftInset + rightInset)
        }
    }
}

func convertDate(from sourceTimeZone: TimeZone, to destinationTimeZone: TimeZone, dateString: String, format: String) -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    dateFormatter.timeZone = sourceTimeZone
    
    if let date = dateFormatter.date(from: dateString) {
        dateFormatter.timeZone = destinationTimeZone
        return dateFormatter.string(from: date)
    }
    
    return nil
}


func getRequiredFormat(dateStrInTwentyFourHourFomat: String) -> String? {

    let dateFormatter = DateFormatter()
//    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
//    dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

    if let newDate = dateFormatter.date(from: dateStrInTwentyFourHourFomat) {

        let timeFormat = DateFormatter()
        timeFormat.timeZone = TimeZone.autoupdatingCurrent
//        timeFormat.locale = Locale(identifier: "en_US_POSIX")
        timeFormat.dateFormat = "MMM d, yyyy hh:mm a"

        let requiredStr = timeFormat.string(from: newDate)
        return requiredStr
    } else {
        return nil
    }
}

func getcommentTimeFormat(dateStrInTwentyFourHourFomat: String) -> String? {

    let dateFormatter = DateFormatter()
//    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
//    dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"

    if let newDate = dateFormatter.date(from: dateStrInTwentyFourHourFomat) {

        let timeFormat = DateFormatter()
        timeFormat.timeZone = TimeZone.autoupdatingCurrent
//        timeFormat.locale = Locale(identifier: "en_US_POSIX")
        timeFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let requiredStr = timeFormat.string(from: newDate)
        return requiredStr
    } else {
        return nil
    }
}

extension Date {
    func toCurrentTimezone() -> Date {
        let timeZoneDifference =
        TimeInterval(TimeZone.current.secondsFromGMT())
        return self.addingTimeInterval(timeZoneDifference)
   }
}


//
//let dateFormatter = DateFormatter()
//dateFormatter.dateFormat = "HH:mm:ss"
//var dateFromStr = dateFormatter.date(from: "12:16:45")!
//
//dateFormatter.dateFormat = "hh:mm:ss a 'on' MMMM dd, yyyy"
////Output: 12:16:45 PM on January 01, 2000
//
//dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
////Output: Sat, 1 Jan 2000 12:16:45 +0600
//
//dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
////Output: 2000-01-01T12:16:45+0600
//
//dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
////Output: Saturday, Jan 1, 2000
//
//dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
////Output: 01-01-2000 12:16
//
//dateFormatter.dateFormat = "MMM d, h:mm a"
////Output: Jan 1, 12:16 PM
//
//dateFormatter.dateFormat = "HH:mm:ss.SSS"
////Output: 12:16:45.000
//
//dateFormatter.dateFormat = "MMM d, yyyy"
////Output: Jan 1, 2000
//
//dateFormatter.dateFormat = "MM/dd/yyyy"
////Output: 01/01/2000
//
//dateFormatter.dateFormat = "hh:mm:ss a"
////Output: 12:16:45 PM
//
//dateFormatter.dateFormat = "MMMM yyyy"
////Output: January 2000
//
//dateFormatter.dateFormat = "dd.MM.yy"
////Output: 01.01.00
//
////Output: Customisable AP/PM symbols
//dateFormatter.amSymbol = "am"
//dateFormatter.pmSymbol = "Pm"
//dateFormatter.dateFormat = "a"
////Output: Pm
//
//// Usage
//var timeFromDate = dateFormatter.string(from: dateFromStr)
//print(timeFromDate)


extension UITableView {
  func scrollToBottom() {

    let lastSectionIndex = self.numberOfSections - 1
    if lastSectionIndex < 0 { //if invalid section
        return
    }

    let lastRowIndex = self.numberOfRows(inSection: lastSectionIndex) - 1
    if lastRowIndex < 0 { //if invalid row
        return
    }

    let pathToLastRow = IndexPath(row: lastRowIndex, section: lastSectionIndex)
    self.scrollToRow(at: pathToLastRow, at: .bottom, animated: true)
  }
}



func deleteVideoFromLocal (path : String)
{

    let filemgr = FileManager.default
    
    if filemgr.fileExists(atPath: path) {
                  do {
                      try filemgr.removeItem(atPath: path)
                      print("Video deleted successfully.")
                  } catch _ {
                  }
              }
}



func getVideoThumbnail(url: URL) -> UIImage? {
    //let url = url as URL
    let request = URLRequest(url: url)
    let cache = URLCache.shared
    if let cachedResponse = cache.cachedResponse(for: request), let image = UIImage(data: cachedResponse.data) {
        return image
    }
    
    let asset = AVAsset(url: url)
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    imageGenerator.maximumSize = CGSize(width: 120, height: 120)
    
    var time = asset.duration
    time.value = min(time.value, 2)
    
    var image: UIImage?
    
    do {
        let cgImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
        image = UIImage(cgImage: cgImage)
    } catch { }
    
    if let image = image, let data = image.pngData(), let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil) {
        let cachedResponse = CachedURLResponse(response: response, data: data)
        let newImg = UIImage(data: data)
        cache.storeCachedResponse(cachedResponse, for: request)
    }
    
    return image
}


extension URL {
    /// Returns a new URL by adding the query items, or nil if the URL doesn't support it.
    /// URL must conform to RFC 3986.
    func appending(_ queryItems: [URLQueryItem]) -> URL? {
        guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            // URL is not conforming to RFC 3986 (maybe it is only conforming to RFC 1808, RFC 1738, and RFC 2732)
            return nil
        }
        // append the query items to the existing ones
        urlComponents.queryItems = (urlComponents.queryItems ?? []) + queryItems

        // return the url from new url components
        return urlComponents.url
    }
}

func count (expDate : String) -> Int {
    print(expDate)
    let dateFormatter1 = DateFormatter()
    let dateFormatter2 = DateFormatter()
    dateFormatter1.dateFormat = "MMM d, yyyy"
    dateFormatter2.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
    let today = dateFormatter2.string(from: Date())
    let formatedStartDate1 = dateFormatter2.date(from: today)
    let formatedStartDate2 = dateFormatter1.date(from: expDate)
    let diffInDays = Calendar.current.dateComponents([.day], from: formatedStartDate1!, to: formatedStartDate2!).day
    print(diffInDays!)
    return diffInDays! + 1
}

extension UIButton {

    static func customSystemButton(title: String, subtitle: String) -> UIButton {
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        style.lineBreakMode = NSLineBreakMode.byWordWrapping

        let titleAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue,
            NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body),
            NSAttributedString.Key.paragraphStyle : style
        ]
        let subtitleAttributes = [
            NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body),
            NSAttributedString.Key.paragraphStyle : style
        ]

        let attributedString = NSMutableAttributedString(string: title, attributes: titleAttributes)
        attributedString.append(NSAttributedString(string: "\n"))
        attributedString.append(NSAttributedString(string: subtitle, attributes: subtitleAttributes))

        let button = UIButton(type: UIButton.ButtonType.system)
        button.setAttributedTitle(attributedString, for: UIControl.State.normal)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping

        return button
    }

}
