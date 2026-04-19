import Testing
@testable import GMovies

@Suite
struct AppLaunchModeTests {

    @Test
    func defaultsToStandard() {
        let sut = AppLaunchMode(environment: [:])

        #expect(sut == .standard)
        #expect(sut.autoLoadsFeatureContent)
        #expect(sut.showsSplashScreen)
    }

    @Test
    func testingModeDisablesSplashAndAutoLoad() {
        let sut = AppLaunchMode(environment: [AppLaunchMode.environmentKey: "testing"])

        #expect(sut == .testing)
        #expect(!sut.autoLoadsFeatureContent)
        #expect(!sut.showsSplashScreen)
    }

    @Test
    func splashDurationFromEnvironment() {
        let duration = AppLaunchMode.splashDuration(
            environment: [AppLaunchMode.splashDurationEnvironmentKey: "0.25"]
        )

        #expect(duration == 0.25)
    }

    @Test
    func splashDurationDefaultsWhenMissing() {
        let duration = AppLaunchMode.splashDuration(environment: [:])

        #expect(duration == AppLaunchMode.defaultSplashDuration)
    }

    @Test
    func splashDurationDefaultsForInvalidValue() {
        let duration = AppLaunchMode.splashDuration(
            environment: [AppLaunchMode.splashDurationEnvironmentKey: "not_a_number"]
        )

        #expect(duration == AppLaunchMode.defaultSplashDuration)
    }

    @Test
    func splashDurationDefaultsForNegativeValue() {
        let duration = AppLaunchMode.splashDuration(
            environment: [AppLaunchMode.splashDurationEnvironmentKey: "-1"]
        )

        #expect(duration == AppLaunchMode.defaultSplashDuration)
    }

    @Test
    func unknownModeDefaultsToStandard() {
        let sut = AppLaunchMode(environment: [AppLaunchMode.environmentKey: "unknown"])

        #expect(sut == .standard)
    }
}
