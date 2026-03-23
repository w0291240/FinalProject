//
//  InputViewController.swift
//  FinalProject
//
//  Created by Jesse Crocker on 2026-03-22.
//

import UIKit

class InputViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textView.layer.borderWidth = 1;
        self.textView.layer.backgroundColor = CGColor(red: 0, green: 100, blue: 0, alpha: 1)
        self.textView.contentInset = UIEdgeInsets(top: 0, left: 5, bottom: 5, right: 5)
        
        self.textView.layer.cornerRadius = 6;

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
