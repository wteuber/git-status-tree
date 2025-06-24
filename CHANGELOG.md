# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [3.0.0] - 2025-06-25

### Added
- Version flag support (`--version`, `-v`) to display the current version
- Help flag support (`--help`, `-h`) to display usage information
- Comprehensive test coverage for version and command-line functionality
- `lib/version.rb` for centralized version management
- RuboCop documentation in README development section
- `CHANGELOG.md` following Keep a Changelog format
- `Gemfile.lock` to version control for consistent dependency versions

### Changed
- **BREAKING**: Ruby version requirement updated to 3.3.1 in `.ruby-version`
- **BREAKING**: Minimum Ruby version in gemspec raised from 2.7 to 3.3
- Updated `git-status-tree.gemspec` to dynamically read version from VERSION file
- Fixed all RuboCop offenses for code style compliance

### Removed
- `.gitignore` file (was only excluding Gemfile.lock, now tracking dependencies)

## [2.0.0] - 2023-02-06

### Added
- CircleCI integration for continuous integration
- Gem version badge in README

### Changed
- **BREAKING**: Dropped support for Ruby < 2.7
- Migrated from Travis CI to CircleCI

## [1.0.1] - 2021-10-07

### Fixed
- Set default node status to '??' for better handling of edge cases

## [1.0.0] - 2021-09-28

### Added
- Initial gem release of git-status-tree
- Executable to add git alias 'tree' during gem installation
- Executable to remove git alias 'tree' during gem uninstallation
- Core functionality to display git repository changes in tree format
- Support for showing file status (added, modified, deleted, untracked)
- Colored output indicating staged (green) vs unstaged (red) changes
- Configurable indentation via `git config --global status-tree.indent`
- Comprehensive test suite
- Support for Ruby 1.9.1 through 3.0.0

### Fixed
- "Try it" section in README documentation

[Unreleased]: https://github.com/knugie/git-status-tree/compare/v3.0.0...HEAD
[3.0.0]: https://github.com/knugie/git-status-tree/compare/v2.0.0...v3.0.0
[2.0.0]: https://github.com/knugie/git-status-tree/compare/v1.0.1...v2.0.0
[1.0.1]: https://github.com/knugie/git-status-tree/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/knugie/git-status-tree/releases/tag/v1.0.0 