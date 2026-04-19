import Testing
@testable import GMovies

@Suite
@MainActor
struct AppDependenciesTests {

    @Test(arguments: [AppEnvironment.dev, .staging, .prod])
    func storesSelectedEnvironment(_ environment: AppEnvironment) {
        let sut = AppDependencies(environment: environment)

        #expect(sut.environment == environment)
    }

    @Test
    func imageURLBuilderUsesEnvironmentBaseURL() {
        let environment = AppEnvironment.current

        let sut = AppDependencies(environment: environment)

        #expect(sut.imageURLBuilder.baseURL == environment.imageBaseURL)
    }
}
