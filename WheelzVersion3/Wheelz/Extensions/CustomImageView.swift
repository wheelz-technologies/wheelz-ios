//
//  CustomImageClass.swift
//  Wheelz
//
//  Created by Arseniy Nikulchenko on 2016-09-17.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit

class CustomImageView: UIImageView {
    
    let progressIndicatorView = CircularLoaderView(frame: CGRect.zero)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func customInit(_ imageUrl: String)
    {
        if(imageUrl != "")
        {
            addSubview(self.progressIndicatorView)
            progressIndicatorView.frame = bounds
            progressIndicatorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
            let url = URL(string: imageUrl)
            self.sd_setImage(with: url, placeholderImage: UIImage(named: "default.png"), options: .cacheMemoryOnly , progress: { [weak self](receivedSize, expectedSize) -> Void in
                self!.progressIndicatorView.progress = CGFloat(receivedSize)/CGFloat(expectedSize)
            }) { [weak self](image, error, _, _) -> Void in
                self!.progressIndicatorView.reveal()
            }
        }
    }
}
