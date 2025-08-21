//
//  MovieTableViewCellModel.swift
//  MovieFlix
//
//  Created by Angelos Staboulis on 11/2/25.
//

import Foundation
final class MovieTableViewCellModel {
    let id: Int?
    let title: String?
    let banner: String?
    let releaseDate: String?
    let vote: String?
    var isFavorite: Bool?
    
    init(model: MovieListResultsModel) {
        self.id = model.id
        self.title = model.title
        self.banner = imagePath + (model.backdrop_path ?? "")
        self.releaseDate = model.release_date
        self.vote = "\(String(describing: model.vote_average))"
        self.isFavorite = false
    }
    
    func setFavorite(to status: Bool) {
       isFavorite = status
    }
}
