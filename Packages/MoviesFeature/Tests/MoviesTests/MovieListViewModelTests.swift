//  MovieListViewModelTests.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Testing
import Foundation
import Networking
import Utilities
@testable import Movies

@Suite(.serialized)
struct MovieListViewModelTests {

    private let token = MockURLProtocol.SerializerToken()

    @MainActor
    private func makeSUT(
        repo: (any PopularMoviesRepository & GenreRepository)? = nil,
        moviesResult: Result<PaginatedResult<Movie>, Error> = .success(
            PaginatedResult(items: [MovieFixtures.makeMovie()], page: 1, totalPages: 3)
        ),
        genresResult: Result<[Genre], Error> = .success([Genre(id: 28, name: "Action")])
    ) -> MovieListViewModel {
        let repository: any PopularMoviesRepository & GenreRepository = repo ?? MockMoviesRepository(
            moviesResult: moviesResult, genresResult: genresResult
        )
        let pagination = PaginationController<Movie> { page in
            try await repository.getPopularMovies(page: page)
        }
        return MovieListViewModel(
            pagination: pagination,
            moviesRepository: repository,
            genreRepository: repository,
            posterPrefetcher: PosterPrefetcher(prefetcher: MockImagePrefetcher()),
            filterViewModel: MovieListFilterViewModel(
                imageURLBuilder: ImageURLBuilder(baseURL: "https://image.tmdb.org/t/p/")
            ),
            connectivity: MockConnectionMonitor()
        )
    }

    @Test @MainActor
    func loadInitial_showsMovies() async {
        let vm = makeSUT()
        await vm.loadInitial()

        #expect(vm.viewState == .loaded)
        #expect(!vm.filteredUIModels.isEmpty)
    }

    @Test @MainActor
    func loadInitial_onError_showsError() async {
        let vm = makeSUT(moviesResult: .failure(URLError(.notConnectedToInternet)))
        await vm.loadInitial()

        if case .error = vm.viewState {} else {
            Issue.record("Expected error state")
        }
    }

    @Test @MainActor
    func loadInitial_emptyResult_showsEmpty() async {
        let vm = makeSUT(moviesResult: .success(PaginatedResult(items: [], page: 1, totalPages: 1)))
        await vm.loadInitial()

        #expect(vm.viewState == .empty)
    }

    @Test @MainActor
    func pagination_appendsNextPage() async {
        let page1 = MovieFixtures.makeMovies(range: 1...10)
        let page2 = MovieFixtures.makeMovies(range: 11...20)
        let repo = MockMoviesRepository()
        repo.pageHandler = { page in
            page == 1
                ? .success(PaginatedResult(items: page1, page: 1, totalPages: 2))
                : .success(PaginatedResult(items: page2, page: 2, totalPages: 2))
        }
        let vm = makeSUT(repo: repo)
        await vm.loadInitial()

        await vm.loadNextPageIfNeeded(currentItemID: page1[6].id)

        #expect(vm.filteredUIModels.count == 20)
    }

    @Test @MainActor
    func pagination_onFailure_showsError_retryWorks() async {
        let page1 = MovieFixtures.makeMovies(range: 1...10)
        let page2 = MovieFixtures.makeMovies(range: 11...20)
        let repo = MockMoviesRepository(
            moviesResult: .success(PaginatedResult(items: page1, page: 1, totalPages: 2))
        )
        let vm = makeSUT(repo: repo)
        await vm.loadInitial()

        repo.moviesResult = .failure(URLError(.notConnectedToInternet))
        await vm.loadNextPageIfNeeded(currentItemID: page1[6].id)
        #expect(vm.pagingError != nil)

        repo.moviesResult = .success(PaginatedResult(items: page2, page: 2, totalPages: 2))
        await vm.retryNextPage()
        #expect(vm.pagingError == nil)
        #expect(vm.filteredUIModels.count == 20)
    }

    @Test @MainActor
    func search_filtersMovies() async {
        let vm = makeSUT()
        await vm.loadInitial()

        vm.filterViewModel.searchQuery = "xyz_not_found"
        #expect(vm.filteredUIModels.isEmpty)

        vm.filterViewModel.searchQuery = ""
        #expect(!vm.filteredUIModels.isEmpty)
    }

    @Test @MainActor
    func genreFilter_filtersMovies() async {
        let vm = makeSUT()
        await vm.loadInitial()

        vm.filterViewModel.selectedGenreID = 999
        #expect(vm.filteredUIModels.isEmpty)

        vm.filterViewModel.selectedGenreID = nil
        #expect(!vm.filteredUIModels.isEmpty)
    }

    @Test @MainActor
    func refresh_updatesData() async {
        let repo = MockMoviesRepository()
        let vm = makeSUT(repo: repo)
        await vm.loadInitial()

        repo.moviesResult = .success(
            PaginatedResult(items: [MovieFixtures.makeMovie(id: 99, title: "Refreshed")], page: 1, totalPages: 1)
        )
        await vm.refresh()

        #expect(vm.filteredUIModels.first?.title == "Refreshed")
    }

    @Test @MainActor
    func refresh_onError_keepsPreviousData() async {
        let repo = MockMoviesRepository()
        let vm = makeSUT(repo: repo)
        await vm.loadInitial()
        let count = vm.filteredUIModels.count

        repo.moviesResult = .failure(URLError(.timedOut))
        await vm.refresh()

        #expect(vm.viewState == .loaded)
        #expect(vm.filteredUIModels.count == count)
    }
}
