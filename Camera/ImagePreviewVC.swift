//
//  ImagePreviewVC.swift
//  Camera
//
//  Created by Hassan Ahmed on 08/09/2017.
//  Copyright © 2017 Hassan Ahmed. All rights reserved.
//

import UIKit

class ImagePreviewVC: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    
    var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.imageView.image = image
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
