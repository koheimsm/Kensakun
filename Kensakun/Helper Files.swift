import Foundation
import UIKit

//Global variables
struct GlobalVariables {
    static let blue = #colorLiteral(red: 0.5500153899, green: 0.8406379819, blue: 0.9600835443, alpha: 1)//UIColor.rbg(r: 129, g: 144, b: 255)
    static let purple = #colorLiteral(red: 0.5500153899, green: 0.8406379819, blue: 0.9600835443, alpha: 1)//UIColor.rbg(r: 161, g: 114, b: 255)
}


//Extensions
//extension UIColor{
  //  class func rbg(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
    //    let color = UIColor.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
      //  return color
    //}
//}
extension UIColor {
    class func rgb(r: Int, g: Int, b: Int, alpha: CGFloat) -> UIColor{
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
    }
}

class RoundedImageView: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius: CGFloat = self.bounds.size.width / 2.0
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
}

class RoundedButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius: CGFloat = self.bounds.size.height / 2.0
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
}
//ButtonValidationHelper
class ButtonValidationHelper {
    
    var textFields: [UITextField]!
    var buttons: [UIButton]!
    
    init(textFields: [UITextField], buttons: [UIButton]) {
        
        self.textFields = textFields
        self.buttons = buttons
        
        
        //attachTargetsToTextFields()
        initialize()
        //disableButton()
        isValidated = false
        //checkForEmptyFields()
    }
    private var isValidated = false {
        didSet {
            if self.isValidated {
                for button in buttons{
                    button.isEnabled = true
                    button.alpha = 1.0
                }
            }else {
                for button in buttons{
                    button.isEnabled = false
                    button.alpha = 0.6
                }
            }
        }
    }

    
    //Attach editing changed listeners to all textfields passed in
    //private func attachTargetsToTextFields() {
      //  for textfield in textFields{
        //    textfield.addTarget(self, action: #selector(textFieldsIsNotEmpty), for: .editingChanged)
        //}
    //}
    private func initialize() {
        for textField in textFields{
            textField.delegate = self as? UITextFieldDelegate
        // TextField の Delegate で変更を検知する方法もありますが .EditingChanged を設定する方が楽なのでこちらで検知してます
            textField.addTarget(self, action: #selector(self.switchingSaveButton), for: .editingChanged)
            self.isValidated = false
        }
    }
    //@objc private func textFieldsIsNotEmpty(sender: UITextField) {
        
        //sender.text = sender.text?.trimmingCharacters(in: .whitespaces)
        //checkForEmptyFields()
    //}
    @objc func switchingSaveButton() {
        for textField in textFields{
            guard let value = textField.text else {
                self.isValidated = false
                return
            }
        // 前後の余白は trim して判定する
            let name = value.trimmingCharacters(in: .whitespaces).uppercased()
            if name.count == 0 || 20 < name.count{
                self.isValidated = false
            } else {
                self.isValidated = true
            }
           
        }
    }

    
    
    //Returns true if the field is empty, false if it not
    //private func checkForEmptyFields() {
        
      //  for textField in textFields{
        //    guard let textFieldVar = textField.text, !textFieldVar.isEmpty else {
                //disableButtons()
          //      isValidated = false
            //    return
            //}
        //}
        //enableButtons()
        //isValidated = true
    //}
    
    //private func enableButtons() {
      //  for button in buttons{
        //    button.isEnabled = true
          //  button.alpha = 1.0
        //}
    //}
    
    //private func disableButtons() {
      //  for button in buttons{
        //    button.isEnabled = false
          //  button.alpha = 0.6
        //}
    //}
    
}

//Enums
enum ViewControllerType {
    case welcome
    case conversations
}

enum PhotoSource {
    case library
    case camera
}

enum ShowExtraView {
    case contacts
    case profile
    case preview
    case map
}

enum MessageType {
    case photo
    case text
    case location
}

enum MessageOwner {
    case sender
    case receiver
}
