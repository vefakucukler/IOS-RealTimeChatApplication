//
//  Helper.swift
//  Chattapp
//
//  Created by Vefa Küçükler on 13.05.2019.
//  Copyright © 2019 Vefa Küçükler. All rights reserved.
//
import UIKit
import Foundation

class Helper
{
    static func dialogMessage(message: String , vc: UIViewController)
    {
        let alert = UIAlertController(title: "Uyarı", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
    
    static func imageLoad(imageView:UIImageView,url:String)
    {
        let downloadTask = URLSession.shared.dataTask(with: URL(string: url)!) { (data, URLResponse, Error) in
            
            if Error == nil && data != nil
            {
                let image = UIImage(data: data!)
                DispatchQueue.main.async {
                    imageView.image = image
                }
            }
            
        }
        downloadTask.resume()
    }

    }

