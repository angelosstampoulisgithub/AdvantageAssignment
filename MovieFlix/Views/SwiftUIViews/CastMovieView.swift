//
//  CastMovieView.swift
//  MovieFlix
//
//  Created by Angelos Staboulis on 21/8/25.
//

import SwiftUI

struct CastMovieView: View {
    var movies: Credits
    
    var body: some View {
        container
            .background(Color.clear)
    }
    
    var container: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            castmovieCollection
        }
    }
    
    var header: some View {
        VStack(alignment: .leading) {
            Text("Cast Movie")
                .foregroundColor(.blue)
                .font(.caption)
                .fontWeight(.bold)
        }
    }
    
    var castmovieCollection: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 48) {
                ForEach(movies.cast, id: \.id) { movie in
                    movieTile(model: movie)
                }
            }
        }
    }
    
    func movieTile(model: Cast) -> some View {
        VStack{
                AsyncImage(url: URL(string:"https://image.tmdb.org/t/p/original" + (model.profilePath ?? ""))) { image in
                    image
                        .resizable()
                        .frame(width: 50, height: 50)
                        .cornerRadius(10)
                        .clipShape(Circle())
                } placeholder: {
                    ProgressView()
                }.frame(width: 50, height: 50)
            Text(model.name!)
            
        }
        
    }
}

