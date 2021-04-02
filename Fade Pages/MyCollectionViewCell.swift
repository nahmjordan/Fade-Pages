//
//  MyCollectionViewCell.swift
//  Fade Pages
//
//  Created by Jordan Nahm on 2021-03-06.
//  Copyright © 2021 Jordan Nahm. All rights reserved.
//

import UIKit

class MyCollectionViewCell: UICollectionViewCell {

    @IBOutlet var imageView: UIImageView!
    
    static let identifier = "MyCollectionViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.isUserInteractionEnabled = true
        //let tapGest = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        //imageView.addGestureRecognizer(tapGest)
        // Initialization code
    }
    
//    @objc func handleTap(recognizer: UITapGestureRecognizer) {
//        let mainVC = ViewController()
//        let drawVC = DrawViewController()
//        let imgSelected = self.imageView.image
//        mainVC.tapOnButton(image: imgSelected)
//    }
    
    public func configure(with image: UIImage) {
        imageView.image = image
        let appDel = UIApplication.shared.delegate as! AppDelegate
        appDel.loadPrevImgCount += 1
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "MyCollectionViewCell", bundle: nil)
    }

}
