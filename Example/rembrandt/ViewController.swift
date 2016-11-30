/**
 * This file is part of Rembrandt
 * Copyright (c) 2016 PhotoEditorSDK.com
 * Licensed under MIT license (https://opensource.org/licenses/MIT)
 */

import UIKit
import rembrandt

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageA = UIImage(named: "imageA")
        let imageB = UIImage(named: "imageB")
        let rembrandt = Rembrandt()
        let result = rembrandt.compare(imageA: imageA!, imageB: imageB!)
        print(result.passed)
        print(result.pixelDifference)
        print(result.percentageDifference)
        imageView.image = result.composition
    }
}

