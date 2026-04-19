# GMovies

A movie discovery app built with SwiftUI, Clean Architecture, and modular SPM packages.

Browse trending movies, filter by genre, search locally, and view full movie details — all with offline support.

## Architecture

The app follows **Clean Architecture** with **MVVM** at the presentation layer.

<p align="center">
  <img src="https://github.com/kudoleh/iOS-Clean-Architecture-MVVM/raw/master/README_FILES/CleanArchitecture%2BMVVM.png" width="600"/>
</p>

Each feature is organized into three layers:

```
Domain          → Entities, protocols, use cases (pure Swift, no frameworks)
Data            → DTOs, mappers, repositories, local/remote data sources
Presentation    → ViewModels, Views, UI models, screens
```

Dependencies flow inward: **Presentation → Domain ← Data**. The domain layer has zero dependencies on UIKit, SwiftUI, or any framework.

## Project Structure

```
Packages/
├── MoviesFeature/                  # Feature package
│   └── Sources/Movies/
│       ├── Domain/
│       │   ├── Entities/           # Movie, Genre, PaginatedResult
│       │   ├── Protocols/          # MoviesRepository (abstractions)
│       │   └── UseCases/           # SearchMoviesUseCase, FilterByGenreUseCase
│       ├── Data/
│       │   ├── Remote/             # DTOs, Mappers, Request definitions
│       │   ├── Local/              # SwiftData models, local data source
│       │   └── Repositories/       # MoviesRepositoryImpl
│       ├── Presentation/
│       │   ├── ViewModels/         # MovieListViewModel, MovieListFilterViewModel
│       │   ├── Views/              # MovieListView, MovieListGridView
│       │   └── Screens/            # MovieListScreen (composition root)
│       └── Composition/            # MoviesDIContainer
│
├── Networking/                     # HTTP client, connectivity, retry
├── Persistence/                    # CachePolicy, SwiftData setup
├── DesignSystem/                   # Shared UI components and tokens
└── Utilities/                      # Formatters, logging, helpers
```

The same structure applies to `MovieDetails` inside `MoviesFeature`.

## Tech Stack

- **SwiftUI** — all views
- **Combine** — reactive filtering pipeline (search + genre), image loading
- **Swift Concurrency** — async/await for networking, repositories, cache
- **SwiftData** — local persistence for offline support
- **XcodeGen** — project file generation from `project.yml`
- **Swift Testing** — `@Test` / `@Suite` for unit tests
- **swift-snapshot-testing** — snapshot tests for DesignSystem

## API

Data comes from [TMDB](https://developer.themoviedb.org):

| Endpoint | Purpose |
|----------|---------|
| `/discover/movie` | Trending movies (paginated) |
| `/genre/movie/list` | Genre list for filter chips |
| `/movie/{id}` | Movie details |

## Setup

**Requirements:** Xcode 26+, Homebrew

```bash
make setup          # install tools + generate project + build
```

Or step by step:

```bash
make install-tools  # install xcodegen
make project        # generate .xcodeproj
make open           # open in Xcode
```

> **Note on API keys:** `Secrets.xcconfig` is committed to the repo intentionally so reviewers can clone, build, and run immediately without any extra setup. In a real project this file would be gitignored and generated via `make keys`.

## Build & Test

```bash
make build-dev      # build Debug-Dev
make test           # run all tests (packages + app)
make test-package   # package tests only
make test-app       # app tests only
make lint           # SwiftLint check
```

## Build Configurations

| Config | Scheme | Bundle ID |
|--------|--------|-----------|
| Debug-Dev | GMovies-Dev | com.mahmoudfares.GMovies.dev |
| Debug-Staging | GMovies-Staging | com.mahmoudfares.GMovies.staging |
| Release-Prod | GMovies-Prod | com.mahmoudfares.GMovies |

Each configuration has its own app icon and TMDB token.
