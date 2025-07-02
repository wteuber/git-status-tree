# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Fixed
- Fixed indentation alignment issue when using custom indent values
  - Tree drawing characters now properly align with specified indentation

### Changed
- Refactored `Node#pre_tree` method to reduce complexity
- Converted multiple methods to Ruby 3.0+ shorthand notation for cleaner code

## [3.2.0] - 2025-06-25

### Added
- Command-line option `-i, --indent INDENT` to set custom indentation (2-10 spaces)
- Parameter support for git alias - `git tree` now accepts all command-line options
- VERSION file now included in gem package to fix version display when installed

### Changed
- Updated `git_add_alias_tree` script to properly pass parameters to git-status-tree

### Fixed
- Fixed `git tree -v` showing "unknown" instead of the actual version number

## [3.1.0] - 2025-01-16

### Added
- Proper support for renamed/moved files in git status
  - Same directory renames show as: `file.rb -> new_file.rb (R+)`
  - Cross-directory moves show full destination path: `file.rb -> lib/file.rb (R+)`
  - Maintains correct tree structure showing original file location
- RuboCop code style checks integrated into test suite
- SimpleCov code coverage analysis
  - Coverage reports generated in `coverage/` directory
  - HTML and JSON format coverage reports
  - Tests fail if coverage drops
  - Can be disabled with `COVERAGE=false` environment variable
- Comprehensive test coverage for GitStatusTree class
- Test coverage for Node status methods (modified?, added?, etc.)
- Test coverage for NodesCollection comparison and validation methods
- Code coverage improved from 87.73% to 100%

### Fixed
- Fixed incorrect tree display for renamed files that previously showed duplicated path structure ([#15](https://github.com/wteuber/git-status-tree/issues/15))

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

[Unreleased]: https://github.com/wteuber/git-status-tree/compare/v3.2.0...HEAD
[3.2.0]: https://github.com/wteuber/git-status-tree/compare/v3.1.0...v3.2.0
[3.1.0]: https://github.com/wteuber/git-status-tree/compare/v3.0.0...v3.1.0
[3.0.0]: https://github.com/wteuber/git-status-tree/compare/v2.0.0...v3.0.0
[2.0.0]: https://github.com/wteuber/git-status-tree/compare/v1.0.1...v2.0.0
[1.0.1]: https://github.com/wteuber/git-status-tree/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/wteuber/git-status-tree/releases/tag/v1.0.0 