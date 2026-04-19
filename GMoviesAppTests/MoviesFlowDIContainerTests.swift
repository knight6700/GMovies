import Testing
@testable import GMovies

@Suite
@MainActor
struct MoviesFlowDIContainerTests {

    @Test
    func makeCoordinatorCreatesFreshInstances() {
        let dependencies = AppDependencies()
        let sut = MoviesFlowDIContainer(dependencies: dependencies)

        let first = sut.makeCoordinator()
        let second = sut.makeCoordinator()

        #expect(first !== second)
    }

    @Test
    func freshCoordinatorStartsWithEmptyPath() {
        let dependencies = AppDependencies()
        let sut = MoviesFlowDIContainer(dependencies: dependencies)

        let coordinator = sut.makeCoordinator()

        #expect(coordinator.path.isEmpty)
    }
}
