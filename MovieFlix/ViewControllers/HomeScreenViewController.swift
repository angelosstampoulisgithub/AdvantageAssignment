//
//  HomeScreenViewController.swift
//  MovieFlix
//
//  Created by Angelos Staboulis on 11/2/25.
//

import UIKit
import Combine
class HomeScreenViewController: UIViewController, MovieTableViewDelegate, UITextFieldDelegate, UITableViewDelegate {
    func movieTableViewDataSource(_: MovieTableViewDataSource, didSelect movie: String?) {
        
    }
    func movieTableViewDataSourceDidAddToFavorites(_: MovieTableViewDataSource) {
        
    }

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var tableView: UITableView!
    private var viewModel = HomeScreenViewModel()
    private var moviesDataSource: MovieTableViewDataSource!
    private var cancellables: Set<AnyCancellable> = []
    private let refresh = UIRefreshControl()
    private var debounceWorkItem: DispatchWorkItem?
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        setupRefresh()
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .allEvents)
        searchTextField.layer.cornerRadius = 10
        searchTextField.layer.borderWidth = 1
        searchTextField.delegate = self
        tableView.delegate = self
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchTextField.becomeFirstResponder()
        loadData()
        setupRefresh()
        searchTextField.layer.cornerRadius = 10
        searchTextField.layer.borderWidth = 1
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .allEvents)
        searchTextField.delegate = self
        tableView.delegate = self
      

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.isSkeletonable = true
        tableView.showAnimatedGradientSkeleton()
        tableView.showAnimatedSkeleton(usingColor: .concrete, transition: .crossDissolve(0.55))
        tableView.hideSkeleton()
        hideKeyboard()
    }
    
    private func loadData(page: Int? = nil) {
        Task { [weak self] in
            guard let self else { return }
            do {
                if page != nil {
                    guard let page else { return }
                    let nextPage = page + 1
                    await viewModel.fetchPopularMovies(with: nextPage)
                    guard let extraData = self.viewModel.popularMovies else { return }
                    self.moviesDataSource.data.append(contentsOf: extraData)
                    tableView.reloadData()
                } else {
                    await viewModel.fetchPopularMovies()
                    configureTableView()
                }
            }
        }
    }
    
    private func setupRefresh() {
        refresh.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresh.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refresh)
    }
    
 
    private func setupTableViewUI() {
        tableView.backgroundColor = UIColor.clear
        tableView.estimatedRowHeight = 50
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.remembersLastFocusedIndexPath = true
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
    }
    func hideKeyboard() -> Void {
           UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    private func configureTableView() {
        tableView.register(MovieTableViewCell.self, forCellReuseIdentifier: "MovieCell")
        if let data = viewModel.popularMovies {
            let favoriteMovies = viewModel.loadFavorites(to: data)
            moviesDataSource = MovieTableViewDataSource(delegate: self, data: favoriteMovies)
            tableView.dataSource = moviesDataSource
            tableView.reloadData()
            setupObservers()
        }
        setupTableViewUI()
        self.tableView.isSkeletonable = false
    }
    
    private func setupObservers() {
        moviesDataSource.addToFavoritesSubject
            .sink { [weak self] id in
                guard let self else { return }
                self.viewModel.addToFavorites(with: id)
            }
            .store(in: &cancellables)
        
        moviesDataSource.removeToFavoritesSubject
            .sink { [weak self] id in
                guard let self else { return }
                self.viewModel.removeFromFavorites(with: id)
            }
            .store(in: &cancellables)
        
        moviesDataSource.openMovieSubject
            .sink { [weak self] id in
                guard let self else { return }
                self.showDetails(with: id)
            }
            .store(in: &cancellables)
        
    }
    
    @objc private func refresh(_ sender: AnyObject) {
        self.loadData()
        self.tableView.reloadData()
        self.refresh.endRefreshing()
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if let searchText = textField.text, !searchText.isEmpty {
            self.seachMovie(text: searchText)
        }
    }
    
    private func seachMovie(text: String) {
        Task { [weak self] in
            guard let self else { return }
            do {
                await viewModel.searchMovie(with: text)
                if let data = viewModel.searchResults {
                    let searchableMovies = viewModel.loadFavorites(to: data)
                    moviesDataSource = MovieTableViewDataSource(delegate: self, data: searchableMovies)
                    tableView.dataSource = moviesDataSource
                    tableView.reloadData()
                }
                moviesDataSource.openMovieSubject
                    .sink { [weak self] id in
                        guard let self else { return }
                        self.showDetails(with: id)
                    }
                    .store(in: &cancellables)
            }
        }
    }
    
    
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        moviesDataSource = MovieTableViewDataSource(delegate: self, data: [])
        tableView.dataSource = moviesDataSource
        tableView.reloadData()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    //MARK: UITableViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let screenHeight = scrollView.frame.size.height
        let threshold = Int(screenHeight * 0.4)
        
        let distanceToBottom = contentHeight - contentOffsetY - screenHeight
        
        if distanceToBottom < CGFloat(threshold) {
            debounceWorkItem?.cancel()
            debounceWorkItem = DispatchWorkItem { [weak self] in
                guard let self else { return }
                self.loadData(page: self.viewModel.page)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: debounceWorkItem!)
            
        }
    }
}

extension HomeScreenViewController {
    func showDetails(with id: Int) {
        if let existingVC = navigationController?.viewControllers.first(where: { $0 is HostingController }) {
            navigationController?.popToViewController(existingVC, animated: true)
            return
        }
        
        let detailsVC = HostingController(rootView: MovieDetailView(viewModel: MovieDetailViewModel(with: id)))
        detailsVC.navigationItem.title = "Movie Details"
        navigationController?.pushViewController(detailsVC, animated: true)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
