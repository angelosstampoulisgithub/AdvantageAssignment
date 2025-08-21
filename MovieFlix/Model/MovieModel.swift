//
//  MovieModel.swift
//  MovieFlix
//
//  Created by Angelos Staboulis on 11/2/25.
//

import Foundation

//MARK: Detail
struct MovieDetailModel: Decodable {
    let id: Int?
    let backdrop_path: String?
    let poster_path: String?
    let genres: [GenreModel]?
    let title: String?
    let overview: String?
    let release_date: String?
    let runtime: Int?
    let vote_average: Double?
    let homepage: String?
    let credits: Credits?
}

struct GenreModel: Decodable {
    let name: String?
    let id: Int?
}

//MARK: Review
struct MovieReviewsModel: Decodable {
    let id: Int?
    let results: [ReviewModel]?
}

struct ReviewModel: Decodable {
    let author: String?
    let content: String?
}

//MARK: Similar
struct SimilarMoviesModel: Decodable {
    let results: [MovieDetailModel]?
}
struct Credits: Decodable {
    let cast: [Cast]
}
struct Cast: Decodable, Identifiable{
    let id: Int?
    let name: String?
    let profilePath: String?
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case profilePath = "profile_path"
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
