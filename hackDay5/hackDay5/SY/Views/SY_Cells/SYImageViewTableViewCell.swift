//
//  SYImageViewTableViewCell.swift
//  hackDay5
//
//  Created by sutie on 30/11/2018.
//  Copyright © 2018 hackDay. All rights reserved.
//

import UIKit

class SYImageViewTableViewCell: UITableViewCell {
    
    var contentImage: String? {
        didSet {
            self.contentsImageView.image = downloadDataFrom(urlString: contentImage!)
        }
    }


    @IBOutlet weak var contentsImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // 여기도 모듈화... 필요
    private func downloadDataFrom(urlString: String) -> UIImage? {
        guard let gifURL = URL(string: urlString) else {
            return nil
        }
        
        do {
            let imageData = try Data(contentsOf: gifURL)
            guard let image = UIImage(data: imageData) else {
                return nil
            }
            return image
        } catch {
            print(error)
        }
        return nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
