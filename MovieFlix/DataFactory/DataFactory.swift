//
//  DataFactory.swift
//  MovieFlix
//
//  Created by Angelos Staboulis on 11/2/25.
//

import Foundation
final class DataFactory {
    func transformMovieData(with initialData: MovieListModel?) -> [MovieTableViewCellModel] {
        guard  let dataList = initialData?.results else { return [] }
        let movieList = dataList.map({ item in
            MovieTableViewCellModel(model: item)
        })
        return movieList
    }
    
    func transformDetailData(with details: MovieDetailModel, reviews: MovieReviewsModel) -> DetailModel {
        let movie = DetailModel(details: details, reviews: reviews)
        return movie
    }
}
