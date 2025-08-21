//
//  HostingController.swift
//  MovieFlix
//
//  Created by Angelos Staboulis on 11/2/25.
//

import Foundation
import Combine
import UIKit
import SwiftUI
final class HostingController: UIHostingController<MovieDetailView> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setupNavigationBar()
    }
    
    func showNavigationBar() {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.title = "Movie Details"
    }
}


extension UINavigationController {
    func setupNavigationBar() {
        navigationBar.isTranslucent = true
        navigationBar.tintColor = .black
        navigationBar.backgroundColor = UIColor.white
        navigationBar.layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
        navigationBar.layer.shadowOffset = CGSize(width: 1.0,height: 1.0)
        navigationBar.layer.shadowRadius = 1.0
        navigationBar.layer.shadowOpacity = 0.5
    }
    
    func setupTransparentNavigationBar() {
        navigationBar.isTranslucent = true
        navigationBar.tintColor = .white
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .clear
            appearance.shadowImage = UIImage()
            appearance.shadowColor = .clear
            appearance.backgroundImage = UIImage()
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
        }
        else {
            navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationBar.shadowImage = UIImage()
            navigationBar.backgroundColor = UIColor.clear
            navigationBar.barTintColor = UIColor.clear
        }
    }
}
