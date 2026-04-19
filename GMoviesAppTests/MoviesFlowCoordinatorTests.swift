import Testing
@testable import GMovies

@Suite
@MainActor
struct MoviesFlowCoordinatorTests {

    @Test
    func showMovieDetailsAppendsRoute() {
        let sut = MoviesFlowCoordinator()

        sut.showMovieDetails(id: 42)

        #expect(sut.path.count == 1)
    }

    @Test
    func goToMovieDetailsAppendsRouteViaRoutingProtocol() {
        let sut = MoviesFlowCoordinator()

        sut.goToMovieDetails(id: 7)

        #expect(sut.path.count == 1)
    }

    @Test
    func popRemovesLastRoute() {
        let sut = MoviesFlowCoordinator()
        sut.showMovieDetails(id: 1)
        sut.showMovieDetails(id: 2)

        sut.pop()

        #expect(sut.path.count == 1)
    }

    @Test
    func popOnEmptyPathDoesNothing() {
        let sut = MoviesFlowCoordinator()

        sut.pop()

        #expect(sut.path.isEmpty)
    }

    @Test
    func popToRootClearsAllRoutes() {
        let sut = MoviesFlowCoordinator()
        sut.showMovieDetails(id: 1)
        sut.showMovieDetails(id: 2)

        sut.popToRoot()

        #expect(sut.path.isEmpty)
    }
}
