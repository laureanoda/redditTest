//
//  RedditTableViewCell.swift
//  redditTest
//
//  Created by Laureano De Andrea on 11/24/19.
//  Copyright © 2019 Laureano De Andrea. All rights reserved.
//

import UIKit

class RedditTableViewCell: UITableViewCell, ImageProviderProtocol {
    
    

    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timAgoLabel: UILabel!
    @IBOutlet weak var commentsCountLabel: UILabel!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var viewedIcon: UIView!
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    var imageProvider: ImageProvider?
    var post: TopResponseChildren? {
        didSet {
            if self.post != nil {
                print(post!.data.thumbnail)
                imageProvider?.getImage(fromUrl: post!.data.thumbnail)
                loading?.startAnimating()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imageProvider = ImageProvider()
        imageProvider?.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        thumbnailImage.image = nil
    }
    
    //MARK: Image Provider Protocol
    
    func didGetImageSuccess(image: UIImage) {
        DispatchQueue.main.async {
            self.loading?.stopAnimating()
            self.thumbnailImage?.image = image
            
        }
        
    }
    
    func didGetImageFailure(error: String) {
        DispatchQueue.main.async {
            self.loading?.stopAnimating()
            self.thumbnailImage?.image = UIImage.init(systemName: "exclamationmark.icloud")
            print(error)
        }
    }

}
