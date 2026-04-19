import Testing
@testable import GMovies

@Suite
@MainActor
struct AppCoordinatorTests {

    @Test
    func preservesInjectedMoviesCoordinator() {
        let moviesCoordinator = MoviesFlowCoordinator()
        let sut = AppCoordinator(moviesCoordinator: moviesCoordinator)

        #expect(sut.moviesCoordinator === moviesCoordinator)
    }

    @Test
    func moviesCoordinatorStartsWithEmptyPath() {
        let sut = AppCoordinator(moviesCoordinator: MoviesFlowCoordinator())

        #expect(sut.moviesCoordinator.path.isEmpty)
    }
}
