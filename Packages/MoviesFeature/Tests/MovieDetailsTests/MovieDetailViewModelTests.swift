import Testing
import Foundation
import Utilities
@testable import MovieDetails

@Suite(.serialized)
struct MovieDetailViewModelTests {

    private let stubDetail = MovieDetail(
        id: 42,
        title: "Interstellar",
        posterPath: "/inter.jpg",
        releaseDate: "2014-11-05",
        genres: [Genre(id: 878, name: "Science Fiction")],
        overview: "A team of explorers travel through a wormhole.",
        homepage: "https://www.interstellar.film",
        budget: 165_000_000,
        revenue: 677_000_000,
        status: "Released",
        runtime: 169,
        spokenLanguages: ["English"]
    )

    @MainActor
    private func makeSUT(
        detailResult: Result<MovieDetail, Error>? = nil,
        fallbackData: MovieDetailFallbackData? = nil
    ) -> (MovieDetailViewModel, MockMovieDetailsRepository) {
        let repo = MockMovieDetailsRepository(detailResult: detailResult ?? .success(stubDetail))
        let vm = MovieDetailViewModel(
            movieID: 42,
            repository: repo,
            fallbackData: fallbackData,
            imageURLBuilder: ImageURLBuilder(baseURL: "https://image.tmdb.org/t/p/")
        )
        return (vm, repo)
    }

    @Test
    @MainActor
    func loadSuccess() async {
        let (vm, _) = makeSUT()
        await vm.load()
        #expect(vm.viewState == .loaded)
        #expect(vm.uiModel?.title == "Interstellar")
    }

    @Test
    @MainActor
    func loadError() async {
        let (vm, _) = makeSUT(detailResult: .failure(URLError(.notConnectedToInternet)))
        await vm.load()
        if case .error = vm.viewState {} else {
            Issue.record("Expected error state, got \(vm.viewState)")
        }
        #expect(vm.uiModel == nil)
    }

    @Test
    @MainActor
    func loadErrorWithFallback() async {
        let fallback = MovieDetailFallbackData(
            title: "Interstellar",
            posterPath: "/inter.jpg",
            releaseYear: 2014,
            overview: "A team of explorers travel through a wormhole."
        )
        let (vm, _) = makeSUT(
            detailResult: .failure(URLError(.notConnectedToInternet)),
            fallbackData: fallback
        )
        await vm.load()
        #expect(vm.viewState == .loaded)
        #expect(vm.uiModel?.title == "Interstellar")
        #expect(vm.uiModel?.overview == "A team of explorers travel through a wormhole.")
        #expect(vm.uiModel?.showOfflineBanner == true)
    }

    @Test
    @MainActor
    func refreshUpdatesData() async {
        let (vm, repo) = makeSUT()
        await vm.load()
        #expect(vm.uiModel?.title == "Interstellar")

        let updated = MovieDetail(
            id: 42,
            title: "Interstellar: IMAX",
            posterPath: "/inter.jpg",
            releaseDate: "2014-11-05",
            genres: [Genre(id: 878, name: "Science Fiction")],
            overview: "Updated overview.",
            homepage: "https://www.interstellar.film",
            budget: 165_000_000,
            revenue: 700_000_000,
            status: "Released",
            runtime: 169,
            spokenLanguages: ["English"]
        )
        repo.detailResult = .success(updated)
        await vm.refresh()

        #expect(vm.viewState == .loaded)
        #expect(vm.uiModel?.title == "Interstellar: IMAX")
    }

    @Test
    @MainActor
    func refreshErrorKeepsPreviousData() async {
        let (vm, repo) = makeSUT()
        await vm.load()
        #expect(vm.uiModel?.title == "Interstellar")

        repo.detailResult = .failure(URLError(.timedOut))
        await vm.refresh()

        #expect(vm.viewState == .loaded)
        #expect(vm.uiModel?.title == "Interstellar")
    }
}
