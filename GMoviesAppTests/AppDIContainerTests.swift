import Testing
@testable import GMovies

@Suite
@MainActor
struct AppDIContainerTests {

    @Test
    func makeRootCoordinatorStartsWithEmptyPath() {
        let sut = AppDIContainer()

        let coordinator = sut.makeRootCoordinator()

        #expect(coordinator.moviesCoordinator.path.isEmpty)
    }

    @Test
    func makeRootCoordinatorCreatesFreshInstances() {
        let sut = AppDIContainer()

        let first = sut.makeRootCoordinator()
        let second = sut.makeRootCoordinator()

        #expect(first !== second)
        #expect(first.moviesCoordinator !== second.moviesCoordinator)
    }
}
