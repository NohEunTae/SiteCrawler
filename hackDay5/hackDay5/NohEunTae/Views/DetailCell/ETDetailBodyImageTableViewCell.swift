//
//  ETDetailBodyImageTableViewCell.swift
//  hackDay5
//
//  Created by user on 2018. 11. 30..
//  Copyright © 2018년 hackDay. All rights reserved.
//

import UIKit

class ETDetailBodyImageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var infoImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    @discardableResult func downloadImage(from url: URL) -> UIImageView {
        self.getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                self.infoImageView.image = UIImage(data: data)
            }
        }
        return self.infoImageView
    }
}
