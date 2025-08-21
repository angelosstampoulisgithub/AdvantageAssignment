//
//  MovieDetailView.swift
//  MovieFlix
//
//  Created by Angelos Staboulis on 11/2/25.
//

import SwiftUI
struct MovieDetailView: View {
    @ObservedObject var viewModel: MovieDetailViewModel
    
    init(viewModel: MovieDetailViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        content
    }
    
    
    var content: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    banner
                        .padding(.horizontal, -54)
                    header
                    vote
                    movieAttributes
                    reviews
                    similarMovies
                    castMovie
                }
                .padding(.horizontal, 8)
                .padding(.top, 16)
            }
        }
    }
    
    var banner: some View {
        AsyncImage(url: URL(string:viewModel.movie?.banner ?? ""))
            .frame(height: 230)
            .cornerRadius(8)
            .overlay(shareOverlay)
    }
    
    var header: some View {
        HStack {
            title
            Spacer()
            favoriteButton
        }
    }
    
    @ViewBuilder
    var title: some View {
        if let model = viewModel.movie {
            VStack(alignment: .leading, spacing: 8) {
                Text(model.title ?? "")
                    .foregroundColor(.black)
                    .font(.title)
                    .fontWeight(.bold)
                Text(model.genres ?? "")
                    .foregroundColor(.gray)
                    .font(.footnote)
                    .fontWeight(.semibold)
            }
        }
    }
    
    @ViewBuilder
    var vote: some View {
        if let model = viewModel.movie {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(model.formatDate(inputDateString: model.releaseDate ?? "") ?? "")
                        .foregroundColor(.orange)
                        .font(.footnote)
                        .fontWeight(.bold)
                    Text((model.voteAvg ?? "") + "/5")
                        .foregroundColor(.black)
                        .font(.footnote)
                        .fontWeight(.bold)
                }
                Spacer()
            }
        }
    }
    
    var favoriteButton: some View {
        Button {
            (viewModel.movie?.isFavorite ?? false) ? viewModel.removeFromFavorites(with: viewModel.movie?.id ?? 0) : viewModel.addToFavorites(with: viewModel.movie?.id ?? 0)
        } label: {
            Image((viewModel.movie?.isFavorite ?? false) ? "Heart" : "Heart_g")
        }
    }
    
    var shareOverlay: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                shareButton
            }.frame(width:400,alignment:.leading)
        }
    }
    
    var shareButton: some View {
        Button {
            viewModel.shareHomePage()
        } label: {
            Image("share")
        }
    }
    
    @ViewBuilder
    var movieAttributes: some View {
        if let model = viewModel.movie {
            MovieAttributesView(detail: model)
        }
    }
    
    @ViewBuilder
    var reviews: some View {
        if let model = viewModel.movie?.reviews, let reviews = viewModel.movie?.transformReviews(with: model) {
            MovieReviewsView(model: reviews)
        }
    }
    
    @ViewBuilder
    var similarMovies: some View {
        if let model = viewModel.similarList {
            SimilarMoviesView(movies: model) { movie in
                self.viewModel.setupMovieData(with: movie)
            }
        }
    }
    @ViewBuilder
    var castMovie: some View {
        if let model = viewModel.detail {
            CastMovieView(movies: model.credits!)
        }
    }
}
