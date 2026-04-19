# Makefile
# GMovies — Project Automation
#
# Created by Mahmoud Fares on 2026.
# Copyright © 2026 Mahmoud Fares. All rights reserved.

SHELL := /bin/bash

.PHONY: menu setup install-tools project open \
        build build-dev build-staging build-prod build-for-testing \
        restore-schemes \
        test test-app test-package test-all test-verbose \
        test-snapshots snapshot-record \
        lint lint-fix \
        clean clean-all clean-snapshots \
        doctor help

PROJECT        := GMovies.xcodeproj
SCHEME_DEV     := GMovies-Dev
SCHEME_STAGING := GMovies-Staging
SCHEME_PROD    := GMovies-Prod
# Simulator destination — matches CI (.github/workflows/ci.yml)
# Pinned to iPhone 17 · iOS 26.2 · arm64 so local builds reproduce CI exactly.
# Override: make test SIM_DEST="platform=iOS Simulator,id=YOUR-UUID"
SIM_NAME       := iPhone 17
SIM_OS         := 26.2
SIM_ARCH       := arm64
SIM_DEST       := platform=iOS Simulator,name=$(SIM_NAME),OS=$(SIM_OS),arch=$(SIM_ARCH)

# Xcode version pinned to match CI
XCODE_VERSION  := 26.2
XCODE_APP      := /Applications/Xcode_$(XCODE_VERSION).app

# Build artifact paths (also referenced by CI)
DERIVED_DATA_PATH := DerivedData
RESULT_BUNDLE     := TestResults.xcresult
REPORTS_DIR       := build/reports

XCODEBUILD     := xcodebuild
XCODEGEN       := xcodegen
SWIFTLINT      := swiftlint

# Secrets file (gitignored) — holds TMDB_ACCESS_TOKEN consumed by xcconfigs
SECRETS_FILE   := GMoviesApp/Config/Secrets.xcconfig
SECRETS_SAMPLE := GMoviesApp/Config/Secrets.xcconfig.example

# Tools to install — default covers local dev (includes swiftlint for `make lint`).
TOOLS ?= xcodegen swiftlint

BOLD   := \033[1m
DIM    := \033[2m
GREEN  := \033[0;32m
BGREEN := \033[1;32m
YELLOW := \033[0;33m
CYAN   := \033[0;36m
BCYAN  := \033[1;36m
RED    := \033[0;31m
WHITE  := \033[1;37m
RESET  := \033[0m

define BANNER
	@printf "\n"
	@printf "$(BCYAN)  ╔══════════════════════════════════════════════════════════════╗$(RESET)\n"
	@printf "$(BCYAN)  ║                                                              ║$(RESET)\n"
	@printf "$(BCYAN)  ║$(RESET)  $(WHITE)██████╗ ███╗   ███╗  ██████╗ ██╗   ██╗██╗███████╗███████╗$(RESET)  $(BCYAN)║$(RESET)\n"
	@printf "$(BCYAN)  ║$(RESET)  $(WHITE)██╔════╝ ████╗ ████║ ██╔═══██╗██║   ██║██║██╔════╝██╔════╝$(RESET)  $(BCYAN)║$(RESET)\n"
	@printf "$(BCYAN)  ║$(RESET)  $(WHITE)██║  ███╗██╔████╔██║ ██║   ██║██║   ██║██║█████╗  ███████╗$(RESET)  $(BCYAN)║$(RESET)\n"
	@printf "$(BCYAN)  ║$(RESET)  $(WHITE)██║   ██║██║╚██╔╝██║ ██║   ██║╚██╗ ██╔╝██║██╔══╝  ╚════██║$(RESET)  $(BCYAN)║$(RESET)\n"
	@printf "$(BCYAN)  ║$(RESET)  $(WHITE)╚██████╔╝██║ ╚═╝ ██║ ╚██████╔╝ ╚████╔╝ ██║███████╗███████║$(RESET)  $(BCYAN)║$(RESET)\n"
	@printf "$(BCYAN)  ║$(RESET)  $(WHITE) ╚═════╝ ╚═╝     ╚═╝  ╚═════╝   ╚═══╝  ╚═╝╚══════╝╚══════╝$(RESET) $(BCYAN)║$(RESET)\n"
	@printf "$(BCYAN)  ║                                                              ║$(RESET)\n"
	@printf "$(BCYAN)  ║$(RESET)  $(DIM)iOS Movie Discovery · Clean Architecture · MVVM · Combine$(RESET)   $(BCYAN)║$(RESET)\n"
	@printf "$(BCYAN)  ║$(RESET)  $(DIM)Copyright © 2026 Mahmoud Fares. All rights reserved.$(RESET)       $(BCYAN)║$(RESET)\n"
	@printf "$(BCYAN)  ║                                                              ║$(RESET)\n"
	@printf "$(BCYAN)  ╚══════════════════════════════════════════════════════════════╝$(RESET)\n"
	@printf "\n"
endef

define STEP
	@printf "$(BCYAN)  ┌──────────────────────────────────────────────────────────────┐$(RESET)\n"
	@printf "$(BCYAN)  │$(RESET)  $(BOLD)Step $(1) of $(2)$(RESET)  $(3)  $(CYAN)$(4)$(RESET)\n"
	@printf "$(BCYAN)  └──────────────────────────────────────────────────────────────┘$(RESET)\n\n"
endef

define HEADER
	@printf "\n  $(1)  $(CYAN)$(BOLD)$(2)$(RESET)  $(DIM)$(3)$(RESET)\n"
	@printf "$(CYAN)  ──────────────────────────────────────────────────────────────$(RESET)\n\n"
endef

define SUCCESS
	@printf "\n"
	@printf "$(BGREEN)  ╔══════════════════════════════════════════════╗$(RESET)\n"
	@printf "$(BGREEN)  ║                                              ║$(RESET)\n"
	@printf "$(BGREEN)  ║   ✅  GMovies is ready!                     ║$(RESET)\n"
	@printf "$(BGREEN)  ║                                              ║$(RESET)\n"
	@printf "$(BGREEN)  ║   $(RESET)run $(CYAN)make open$(RESET) to launch Xcode$(BGREEN)            ║$(RESET)\n"
	@printf "$(BGREEN)  ║                                              ║$(RESET)\n"
	@printf "$(BGREEN)  ╚══════════════════════════════════════════════╝$(RESET)\n"
	@printf "\n"
endef

menu: ## 🎯 Interactive target picker (default)
	$(BANNER)
	@printf "  🚀  $(BOLD)Setup$(RESET)\n"
	@printf "$(CYAN)  ──────────────────────────────────────────────────────────────$(RESET)\n"
	@printf "   $(BCYAN) 1$(RESET)  ⭐  Full Setup  $(DIM)tools → keys → secrets → project → build$(RESET)\n"
	@printf "   $(BCYAN) 2$(RESET)  🔧  Install Tools\n"
	@printf "   $(BCYAN) 3$(RESET)  🔑  Configure API Keys\n"
	@printf "   $(BCYAN) 4$(RESET)  🔐  Verify Secrets  $(DIM)(checks Secrets.xcconfig exists)$(RESET)\n"
	@printf "   $(BCYAN) 5$(RESET)  📐  Generate Xcode Project  $(DIM)(XcodeGen)$(RESET)\n"
	@printf "\n"
	@printf "  🏗️   $(BOLD)Build$(RESET)\n"
	@printf "$(CYAN)  ──────────────────────────────────────────────────────────────$(RESET)\n"
	@printf "   $(BCYAN) 6$(RESET)  🟢  Build Dev\n"
	@printf "   $(BCYAN) 7$(RESET)  🟡  Build Staging\n"
	@printf "   $(BCYAN) 8$(RESET)  🔴  Build Prod\n"
	@printf "\n"
	@printf "  🧪  $(BOLD)Test$(RESET)\n"
	@printf "$(CYAN)  ──────────────────────────────────────────────────────────────$(RESET)\n"
	@printf "   $(BCYAN) 9$(RESET)  🧪  Run All Tests  $(DIM)(MoviesFeature package + GMovies app tests)$(RESET)\n"
	@printf "   $(BCYAN)10$(RESET)  ⚡  Run Package Tests  $(DIM)(MoviesFeature package targets only)$(RESET)\n"
	@printf "   $(BCYAN)11$(RESET)  📸  Run Snapshot Tests Only\n"
	@printf "   $(BCYAN)12$(RESET)  🔴  Record Snapshots  $(DIM)(overwrites references)$(RESET)\n"
	@printf "   $(BCYAN)13$(RESET)  $(DIM)(reserved)$(RESET)\n"
	@printf "\n"
	@printf "  🔍  $(BOLD)Quality$(RESET)\n"
	@printf "$(CYAN)  ──────────────────────────────────────────────────────────────$(RESET)\n"
	@printf "   $(BCYAN)14$(RESET)  🔍  Lint  $(DIM)(report only)$(RESET)\n"
	@printf "   $(BCYAN)15$(RESET)  🛠️   Lint Fix  $(DIM)(auto-fix violations)$(RESET)\n"
	@printf "\n"
	@printf "  🧹  $(BOLD)Clean$(RESET)\n"
	@printf "$(CYAN)  ──────────────────────────────────────────────────────────────$(RESET)\n"
	@printf "   $(BCYAN)16$(RESET)  🧹  Clean Build Artifacts\n"
	@printf "   $(BCYAN)17$(RESET)  💣  Clean All  $(DIM)(includes .xcodeproj + Secrets.xcconfig)$(RESET)\n"
	@printf "   $(BCYAN)18$(RESET)  🗑️   Clean Snapshots  $(DIM)(remove reference images)$(RESET)\n"
	@printf "\n"
	@printf "  📂  $(BOLD)Project$(RESET)\n"
	@printf "$(CYAN)  ──────────────────────────────────────────────────────────────$(RESET)\n"
	@printf "   $(BCYAN)19$(RESET)  📂  Open in Xcode\n"
	@printf "   $(BCYAN)20$(RESET)  🩺  Doctor  $(DIM)(verify Xcode/sim match CI)$(RESET)\n"
	@printf "\n"
	@printf "  $(BOLD)Choose [1-20]:$(RESET) "; \
	read -r choice; \
	printf "\n"; \
	case $$choice in \
		1)  $(MAKE) --no-print-directory setup ;; \
		2)  $(MAKE) --no-print-directory install-tools ;; \
		3)  $(MAKE) --no-print-directory keys ;; \
		4)  $(MAKE) --no-print-directory secrets ;; \
		5)  $(MAKE) --no-print-directory project ;; \
		6)  $(MAKE) --no-print-directory build-dev ;; \
		7)  $(MAKE) --no-print-directory build-staging ;; \
		8)  $(MAKE) --no-print-directory build-prod ;; \
		9)  $(MAKE) --no-print-directory test ;; \
		10) $(MAKE) --no-print-directory test-package ;; \
		11) $(MAKE) --no-print-directory test-snapshots ;; \
		12) $(MAKE) --no-print-directory snapshot-record ;; \
		14) $(MAKE) --no-print-directory lint ;; \
		15) $(MAKE) --no-print-directory lint-fix ;; \
		16) $(MAKE) --no-print-directory clean ;; \
		17) $(MAKE) --no-print-directory clean-all ;; \
		18) $(MAKE) --no-print-directory clean-snapshots ;; \
		19) $(MAKE) --no-print-directory open ;; \
		20) $(MAKE) --no-print-directory doctor ;; \
		*)  printf "  ❌  $(RED)Invalid choice: $$choice$(RESET)\n\n"; exit 1 ;; \
	esac

setup: ## ⭐ Full setup (tools → project → build)
	$(BANNER)
	$(call STEP,1,3,🔧,Install Required Tools)
	@$(MAKE) --no-print-directory install-tools
	@printf "\n"
	$(call STEP,2,3,📐,Generate Xcode Project)
	@$(MAKE) --no-print-directory project
	@printf "\n"
	$(call STEP,3,3,🏗️,Build — Debug Dev)
	@$(MAKE) --no-print-directory build-dev
	$(SUCCESS)

install-tools: ## 🔧 Install tools via Homebrew / RubyGems (override with TOOLS=…)
	$(call HEADER,🔧,Install Tools,$(TOOLS))
	@tool_ok=1; \
	for tool in $(TOOLS); do \
		if command -v $$tool > /dev/null 2>&1; then \
			printf "  ✅  $$tool $(DIM)already installed$(RESET)\n"; \
		else \
			printf "  🔄  Installing $$tool...\n"; \
			brew install $$tool && \
			printf "  ✅  $$tool installed\n" || \
			{ printf "  ❌  $(RED)Failed to install $$tool$(RESET)\n"; tool_ok=0; }; \
		fi; \
	done; \
	[ $$tool_ok -eq 1 ] && printf "\n  ✅  $(BGREEN)All tools ready$(RESET)\n" || exit 1

keys: ## 🔑 Write Secrets.xcconfig — per-env tokens, empty values fall back to Dev
	$(call HEADER,🔑,TMDB Access Tokens,Dev · Staging · Prod)
	@# Overwrite guard — only when interactive + no env var hints
	@if [ -f $(SECRETS_FILE) ] \
	   && [ -z "$$TMDB_ACCESS_TOKEN" ] \
	   && [ -z "$$TMDB_ACCESS_TOKEN_DEV" ] \
	   && [ -z "$$TMDB_ACCESS_TOKEN_STAGING" ] \
	   && [ -z "$$TMDB_ACCESS_TOKEN_PROD" ] \
	   && [ -t 0 ]; then \
		printf "  ⚠️   $(YELLOW)$(SECRETS_FILE) already exists. Overwrite?$(RESET) [y/N] "; \
		read -r confirm; \
		if [ "$$confirm" != "y" ] && [ "$$confirm" != "Y" ]; then \
			printf "\n  ℹ️   $(CYAN)Keeping existing $(SECRETS_FILE)$(RESET)\n"; \
			exit 0; \
		fi; \
	fi
	@dev_token="$$TMDB_ACCESS_TOKEN_DEV"; \
	staging_token="$$TMDB_ACCESS_TOKEN_STAGING"; \
	prod_token="$$TMDB_ACCESS_TOKEN_PROD"; \
	if [ -z "$$dev_token" ] && [ -z "$$staging_token" ] && [ -z "$$prod_token" ] && [ -n "$$TMDB_ACCESS_TOKEN" ]; then \
		dev_token="$$TMDB_ACCESS_TOKEN"; \
		printf "  ℹ️   Using $(CYAN)\$$TMDB_ACCESS_TOKEN$(RESET) for Dev (Staging/Prod will fall back)\n"; \
	elif [ -n "$$dev_token$$staging_token$$prod_token" ]; then \
		printf "  ℹ️   Using per-env env vars\n"; \
	fi; \
	if [ -z "$$dev_token" ] && [ -z "$$staging_token" ] && [ -z "$$prod_token" ]; then \
		if [ -t 0 ]; then \
			printf "  $(DIM)Paste your TMDB v4 Bearer tokens. Leave Staging/Prod empty to reuse Dev.$(RESET)\n\n"; \
			printf "  🟢  $(BOLD)Dev$(RESET)     $(DIM)(required)$(RESET)\n"; \
			read -rp "    🔑  Access Token: " dev_token; \
			printf "\n  🟡  $(BOLD)Staging$(RESET) $(DIM)(blank → reuse Dev)$(RESET)\n"; \
			read -rp "    🔑  Access Token: " staging_token; \
			printf "\n  🔴  $(BOLD)Prod$(RESET)    $(DIM)(blank → reuse Dev)$(RESET)\n"; \
			read -rp "    🔑  Access Token: " prod_token; \
			printf "\n"; \
		else \
			printf "  ❌  $(RED)No token. Set \$$TMDB_ACCESS_TOKEN (or \$$TMDB_ACCESS_TOKEN_DEV) or run interactively$(RESET)\n\n"; \
			exit 1; \
		fi; \
	fi; \
	if [ -z "$$dev_token" ]; then \
		printf "  ❌  $(RED)Dev token cannot be empty$(RESET)\n\n"; exit 1; \
	fi; \
	if [ -z "$$staging_token" ]; then staging_token="$$dev_token"; printf "  $(DIM)  ↳ Staging reuses Dev$(RESET)\n"; fi; \
	if [ -z "$$prod_token"    ]; then prod_token="$$dev_token";    printf "  $(DIM)  ↳ Prod reuses Dev$(RESET)\n"; fi; \
	printf "// Secrets.xcconfig\n\
// GMovies — TMDB API tokens  ·  ⚠️ Never commit this file\n\
// Generated by: make keys\n\
\n\
TMDB_ACCESS_TOKEN_DEV     = $$dev_token\n\
TMDB_ACCESS_TOKEN_STAGING = $$staging_token\n\
TMDB_ACCESS_TOKEN_PROD    = $$prod_token\n" > $(SECRETS_FILE); \
	printf "\n  ✅  $(BGREEN)$(SECRETS_FILE) written$(RESET)\n"

secrets: ## 🔐 Verify Secrets.xcconfig exists (no-op shim kept for CI/backward-compat)
	$(call HEADER,🔐,Verify Secrets,$(SECRETS_FILE))
	@if [ ! -f $(SECRETS_FILE) ]; then \
		printf "  ❌  $(RED)$(SECRETS_FILE) not found — run$(RESET) $(CYAN)make keys$(RESET)\n"; \
		printf "  $(DIM)  (or copy $(SECRETS_SAMPLE) and fill in your token)$(RESET)\n\n"; \
		exit 1; \
	fi
	@printf "  ✅  $(BGREEN)$(SECRETS_FILE) present$(RESET)\n"

# ── Auto-bootstrap rule ───────────────────────────────────────
# When any target has `| $(SECRETS_FILE)` as an order-only prereq, this rule
# fires if the file is missing — auto-invoking `make keys` (env var or prompt).
$(SECRETS_FILE):
	@printf "\n  ℹ️   $(YELLOW)$(SECRETS_FILE) missing — bootstrapping via $(CYAN)make keys$(RESET)\n"
	@$(MAKE) --no-print-directory keys

project: restore-schemes ## 📐 Regenerate GMovies.xcodeproj from project.yml via XcodeGen
	$(call HEADER,📐,Generate Xcode Project,XcodeGen → project.yml)
	@printf "  🔄  Running XcodeGen...\n"
	@$(XCODEGEN) generate 2>&1 | sed 's/^/    /'
	@# Copy custom schemes into generated project
	@# (package test targets need manual scheme wiring)
	@if [ -d .xcodegen/xcschemes ]; then \
		mkdir -p $(PROJECT)/xcshareddata/xcschemes && \
		cp -f .xcodegen/xcschemes/*.xcscheme $(PROJECT)/xcshareddata/xcschemes/ 2>/dev/null; \
		printf "  ✅  Overlaid custom schemes from .xcodegen/xcschemes\n"; \
	fi
	@printf "\n  ✅  $(BGREEN)$(PROJECT) ready$(RESET)\n"

restore-schemes:
	@true

open: ## 📂 Open GMovies.xcodeproj in Xcode
	@printf "\n  📂  Opening in Xcode...\n\n"
	@open $(PROJECT)

build: build-dev ## 🏗️ Build (alias for build-dev)

build-dev: ## 🟢 Build Debug-Dev scheme
	$(call HEADER,🟢,Build Dev,Debug-Dev · iOS Simulator)
	@$(XCODEBUILD) build \
		-project $(PROJECT) \
		-scheme $(SCHEME_DEV) \
		-destination '$(SIM_DEST)' \
		-configuration Debug-Dev \
		-derivedDataPath $(DERIVED_DATA_PATH) \
		CODE_SIGNING_ALLOWED=NO \
		
	@printf "\n  ✅  $(BGREEN)Build succeeded — Dev$(RESET)\n"

build-for-testing: ## 🏗️ Build test bundle only (CI-optimized — caches DerivedData)
	$(call HEADER,🏗️,Build for Testing,Debug-Dev · GMovies-Dev scheme)
	@$(XCODEBUILD) build-for-testing \
		-project $(PROJECT) \
		-scheme $(SCHEME_DEV) \
		-destination '$(SIM_DEST)' \
		-configuration Debug-Dev \
		-derivedDataPath $(DERIVED_DATA_PATH) \
		CODE_SIGNING_ALLOWED=NO \
		
	@printf "\n  ✅  $(BGREEN)Test bundle built$(RESET)\n"

build-staging: ## 🟡 Build Debug-Staging scheme
	$(call HEADER,🟡,Build Staging,Debug-Staging · iOS Simulator)
	@$(XCODEBUILD) build \
		-project $(PROJECT) \
		-scheme $(SCHEME_STAGING) \
		-destination '$(SIM_DEST)' \
		-configuration Debug-Staging \
		-derivedDataPath $(DERIVED_DATA_PATH) \
		CODE_SIGNING_ALLOWED=NO \
		
	@printf "\n  ✅  $(BGREEN)Build succeeded — Staging$(RESET)\n"

build-prod: ## 🔴 Build Release-Prod scheme
	$(call HEADER,🔴,Build Prod,Release-Prod · iOS Simulator)
	@$(XCODEBUILD) build \
		-project $(PROJECT) \
		-scheme $(SCHEME_PROD) \
		-destination '$(SIM_DEST)' \
		-configuration Release-Prod \
		-derivedDataPath $(DERIVED_DATA_PATH) \
		CODE_SIGNING_ALLOWED=NO \
		
	@printf "\n  ✅  $(BGREEN)Build succeeded — Prod$(RESET)\n"

test: ## 🧪 Run ALL tests (MoviesFeature package + GMovies app)
	@$(MAKE) --no-print-directory test-package
	@$(MAKE) --no-print-directory test-app
	@printf "\n  ✅  $(BGREEN)All tests complete$(RESET)\n"

test-app: ## 📱 Run app tests (GMoviesTests target / GMoviesAppTests sources)
	$(call HEADER,📱,Test App,GMoviesTests target)
	@mkdir -p $(REPORTS_DIR)
	@rm -rf $(RESULT_BUNDLE)
	@set -o pipefail; $(XCODEBUILD) test \
		-project $(PROJECT) \
		-scheme $(SCHEME_DEV) \
		-destination '$(SIM_DEST)' \
		-configuration Debug-Dev \
		-derivedDataPath $(DERIVED_DATA_PATH) \
		-resultBundlePath $(RESULT_BUNDLE) \
		-enableCodeCoverage YES \
		-only-testing:GMoviesTests \
		-parallel-testing-enabled NO \
		CODE_SIGNING_ALLOWED=NO \
		2>&1 | tee $(REPORTS_DIR)/xcodebuild-app.log
	@printf "\n  ✅  $(BGREEN)App tests complete$(RESET)\n"

test-verbose: restore-schemes ## 🔊 Run all tests with raw output
	$(call HEADER,🔊,Test (verbose),Package + App · raw output)
	@mkdir -p $(REPORTS_DIR)
	@rm -rf $(RESULT_BUNDLE)
	@set -o pipefail; cd Packages/MoviesFeature && $(XCODEBUILD) test \
		-scheme MoviesFeature-Package \
		-destination '$(SIM_DEST)' \
		-derivedDataPath ../../$(DERIVED_DATA_PATH) \
		-resultBundlePath ../../$(RESULT_BUNDLE) \
		-enableCodeCoverage YES \
		-only-testing:MoviesTests \
		-only-testing:MovieDetailsTests \
		-parallel-testing-enabled NO \
		CODE_SIGNING_ALLOWED=NO \
		2>&1 | tee ../../$(REPORTS_DIR)/xcodebuild-package.log
	@set -o pipefail; $(XCODEBUILD) test \
		-project $(PROJECT) \
		-scheme $(SCHEME_DEV) \
		-destination '$(SIM_DEST)' \
		-configuration Debug-Dev \
		-derivedDataPath $(DERIVED_DATA_PATH) \
		-enableCodeCoverage YES \
		-only-testing:GMoviesTests \
		-parallel-testing-enabled NO \
		CODE_SIGNING_ALLOWED=NO \
		2>&1 | tee $(REPORTS_DIR)/xcodebuild-app.log
	@printf "\n  ✅  $(BGREEN)All tests complete$(RESET)\n"

test-package: restore-schemes ## ⚡ Run all test targets via MoviesFeature-Package scheme
	$(call HEADER,⚡,Test Package,All package tests)
	@mkdir -p $(REPORTS_DIR)
	@rm -rf $(RESULT_BUNDLE)
	$(call HEADER,📦,Test Utilities,Utilities-Package scheme)
	@echo "Testing Utilities..."
	@cd Packages/Utilities && $(XCODEBUILD) test \
		-scheme Utilities-Package \
		-destination '$(SIM_DEST)' \
		-derivedDataPath ../../$(DERIVED_DATA_PATH) \
		-parallel-testing-enabled NO \
		CODE_SIGNING_ALLOWED=NO \
		2>&1 | tail -5
	$(call HEADER,📦,Test Networking,Networking-Package scheme)
	@echo "Testing Networking..."
	@cd Packages/Networking && $(XCODEBUILD) test \
		-scheme Networking-Package \
		-destination '$(SIM_DEST)' \
		-derivedDataPath ../../$(DERIVED_DATA_PATH) \
		-parallel-testing-enabled NO \
		CODE_SIGNING_ALLOWED=NO \
		2>&1 | tail -5
	$(call HEADER,📦,Test Persistence,Persistence-Package scheme)
	@echo "Testing Persistence..."
	@cd Packages/Persistence && $(XCODEBUILD) test \
		-scheme Persistence-Package \
		-destination '$(SIM_DEST)' \
		-derivedDataPath ../../$(DERIVED_DATA_PATH) \
		-parallel-testing-enabled NO \
		CODE_SIGNING_ALLOWED=NO \
		2>&1 | tail -5
	$(call HEADER,🎬,Test MoviesFeature,MoviesFeature-Package scheme)
	@echo "Testing MoviesFeature..."
	@set -o pipefail; cd Packages/MoviesFeature && $(XCODEBUILD) test \
		-scheme MoviesFeature-Package \
		-destination '$(SIM_DEST)' \
		-derivedDataPath ../../$(DERIVED_DATA_PATH) \
		-resultBundlePath ../../$(RESULT_BUNDLE) \
		-enableCodeCoverage YES \
		-only-testing:MoviesTests \
		-only-testing:MovieDetailsTests \
		-parallel-testing-enabled NO \
		CODE_SIGNING_ALLOWED=NO \
		2>&1 | tee ../../$(REPORTS_DIR)/xcodebuild-package.log
	@printf "\n  ✅  $(BGREEN)All package tests complete$(RESET)\n"

test-snapshots: restore-schemes ## 📸 Run snapshot tests only (DesignSystemSnapshotTests)
	$(call HEADER,📸,Snapshot Tests,DesignSystemSnapshotTests)
	@cd Packages/DesignSystem && $(XCODEBUILD) test \
		-scheme DesignSystem-Package \
		-destination '$(SIM_DEST)' \
		-derivedDataPath ../../$(DERIVED_DATA_PATH) \
		-only-testing:DesignSystemSnapshotTests \
		CODE_SIGNING_ALLOWED=NO \
		
	@printf "\n  ✅  $(BGREEN)Snapshot tests complete$(RESET)\n"

snapshot-record: restore-schemes ## 🔴 Record / update snapshot reference images
	$(call HEADER,🔴,Record Snapshots,Overwrites reference images in DesignSystemSnapshotTests)
	@printf "  ⚠️   $(YELLOW)This will overwrite all existing snapshot reference images.$(RESET)\n\n"
	@cd Packages/DesignSystem && SNAPSHOT_TESTING_RECORD=all $(XCODEBUILD) test \
		-scheme DesignSystem-Package \
		-destination '$(SIM_DEST)' \
		-derivedDataPath ../../$(DERIVED_DATA_PATH) \
		-only-testing:DesignSystemSnapshotTests \
		CODE_SIGNING_ALLOWED=NO \
		
	@printf "\n  ✅  $(BGREEN)Snapshots recorded$(RESET)\n"

clean-snapshots: ## 🗑️ Delete all snapshot reference images
	$(call HEADER,🗑️,Clean Snapshots,Remove reference images)
	@find . -path '*/GMoviesSnapshotTests/__Snapshots__' -type d -exec rm -rf {} + 2>/dev/null || true
	@printf "\n  ✅  $(BGREEN)Snapshot reference images removed$(RESET)\n"

test-all: test ## 🔬 Alias for `make test` (runs package + app + snapshots)

lint: ## 🔍 Run SwiftLint (report only)
	$(call HEADER,🔍,Lint,SwiftLint · report only)
	@$(SWIFTLINT) lint --config .swiftlint.yml

lint-fix: ## 🛠️ Run SwiftLint and auto-fix violations
	$(call HEADER,🛠️,Lint Fix,SwiftLint · auto-fix)
	@$(SWIFTLINT) --fix --config .swiftlint.yml
	@$(SWIFTLINT) lint --config .swiftlint.yml
	@printf "\n  ✅  $(BGREEN)Lint complete$(RESET)\n"

clean: ## 🧹 Remove build artifacts and DerivedData
	$(call HEADER,🧹,Clean,Build artifacts · DerivedData · Test results)
	@printf "  🔄  Cleaning Xcode build...\n"
	@$(XCODEBUILD) clean -project $(PROJECT) -scheme $(SCHEME_DEV) -quiet 2>/dev/null || true
	@printf "  🔄  Removing DerivedData (local + global)...\n"
	@rm -rf $(DERIVED_DATA_PATH)
	@rm -rf ~/Library/Developer/Xcode/DerivedData/GMovies-*
	@printf "  🔄  Removing package build caches...\n"
	@rm -rf Packages/MoviesFeature/.build Packages/Utilities/.build Packages/Networking/.build Packages/Persistence/.build Packages/DesignSystem/.build
	@printf "  🔄  Removing test results & reports...\n"
	@rm -rf $(RESULT_BUNDLE) $(REPORTS_DIR)
	@printf "\n  ✅  $(BGREEN)Cleaned$(RESET)\n"

clean-all: clean ## 💣 Remove all generated files (.xcodeproj + Secrets.xcconfig)
	@printf "  🔄  Removing $(PROJECT)...\n"
	@rm -rf $(PROJECT)
	@printf "  🔄  Removing $(SECRETS_FILE) (you'll need to re-enter TMDB token)...\n"
	@rm -f $(SECRETS_FILE)
	@printf "\n  ✅  $(BGREEN)All generated files removed$(RESET)\n"
	@printf "  $(DIM)Run $(RESET)$(CYAN)make setup$(RESET)$(DIM) to regenerate everything$(RESET)\n\n"

doctor: ## 🩺 Verify local toolchain matches CI (Xcode 26.2 · iPhone 17 · iOS 26.2)
	$(call HEADER,🩺,Doctor,Verify local toolchain matches CI)
	@printf "  $(BOLD)Expected (from CI)$(RESET)\n"
	@printf "    Xcode:      $(CYAN)$(XCODE_VERSION)$(RESET)    at  $(DIM)$(XCODE_APP)$(RESET)\n"
	@printf "    Simulator:  $(CYAN)$(SIM_NAME)$(RESET)  on iOS $(CYAN)$(SIM_OS)$(RESET)  ($(SIM_ARCH))\n\n"
	@printf "  $(BOLD)Actual$(RESET)\n"
	@if [ -d "$(XCODE_APP)" ]; then \
		printf "    ✅  $(XCODE_APP) exists\n"; \
	else \
		printf "    ❌  $(RED)$(XCODE_APP) not found$(RESET) — install Xcode $(XCODE_VERSION) or update XCODE_VERSION in Makefile\n"; \
	fi
	@active=$$(xcode-select -p 2>/dev/null); \
	printf "    📍  Active DEVELOPER_DIR: $(DIM)$$active$(RESET)\n"; \
	if [ "$$active" != "$(XCODE_APP)/Contents/Developer" ]; then \
		printf "    ⚠️   $(YELLOW)Run:$(RESET) $(CYAN)sudo xcode-select -s $(XCODE_APP)$(RESET)\n"; \
	fi
	@printf "\n  $(BOLD)Installed iOS 26 runtimes$(RESET)\n"
	@xcrun simctl list runtimes 2>/dev/null | grep -i "iOS 26" | sed 's/^/    /' || printf "    ❌  $(RED)No iOS 26 runtime installed$(RESET)\n"
	@printf "\n  $(BOLD)Matching simulators (name=$(SIM_NAME))$(RESET)\n"
	@xcrun simctl list devices available 2>/dev/null | grep "$(SIM_NAME)" | sed 's/^/    /' || printf "    ❌  $(RED)No '$(SIM_NAME)' simulator found$(RESET)\n"
	@printf "\n  $(BOLD)Destination string$(RESET)\n    $(CYAN)$(SIM_DEST)$(RESET)\n\n"

help: ## 📋 Show all available targets
	@printf "\n$(BCYAN)  ╔══════════════════════════════════════════════════════════════╗$(RESET)\n"
	@printf "$(BCYAN)  ║$(RESET)  $(BOLD)GMovies — Available make targets$(RESET)                              $(BCYAN)║$(RESET)\n"
	@printf "$(BCYAN)  ╚══════════════════════════════════════════════════════════════╝$(RESET)\n\n"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; \
		       {printf "  $(CYAN)%-18s$(RESET) %s\n", $$1, $$2}'
	@printf "\n"

.DEFAULT_GOAL := menu
