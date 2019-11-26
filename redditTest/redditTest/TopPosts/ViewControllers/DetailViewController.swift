//
//  DetailViewController.swift
//  redditTest
//
//  Created by Laureano De Andrea on 11/24/19.
//  Copyright © 2019 Laureano De Andrea. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, ImageProviderProtocol {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var post: TopResponseChildrenData?
    var imageProvider: ImageProvider?
    
    override func viewDidLoad() {
        imageProvider = ImageProvider()
        imageProvider!.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if post != nil {
            self.detailDescriptionLabel.text = post!.title
            loadingIndicator.startAnimating()
            imageProvider!.getImage(fromUrl: post!.thumbnail)
        }
    }

    //MARK: Image Provider Protocol

    func didGetImageSuccess(image: UIImage) {
        DispatchQueue.main.async {
            self.thumbnailImage.image = image
            self.loadingIndicator.stopAnimating()
        }
        
    }

    func didGetImageFailure(error: String) {
        DispatchQueue.main.async {
            print(error)
            self.loadingIndicator.stopAnimating()
        }
    }

}

