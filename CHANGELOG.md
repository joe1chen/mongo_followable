# Changelog

All notable changes to this project are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.5.0] - 2026-10-01
DOGOnews fork. Minor version because no runtime requirement rose and `lib/` is unchanged since 0.4.2 (CI,
specs, documentation and release tooling only).

### Added
- GitHub Actions test matrix (`.github/workflows/test.yml`), seven rows from Ruby 2.7 / Rails 6.1 /
  Mongoid 7.5 / MongoDB 6.0 to Ruby 3.4 / Rails 8.0 / Mongoid 9.0 / MongoDB 8.0. The `Gemfile` selects
  Rails and Mongoid from `RAILS_VERSION` / `MONGOID_VERSION` (defaults 6.1 / 7.5).
- GitHub Release workflow (`.github/workflows/release.yml`): pushing a `vX.Y.Z` tag creates a GitHub Release
  with this file's section as the notes.

### Changed
- `master` carries the 0.4.x line: the `integration` branch (optimized follow schema) was merged into `master`
  in 2021. `integration` is kept as a legacy alias that tracks `master`.
- Runtime dependency `mongoid_magic_counter_cache` without a version constraint (was `>= 1.1.1`).
- Development dependencies: `mongoid >= 7.0, < 10`, RSpec 3.13 (keeping the `should` syntax, enabled
  explicitly) and `database_cleaner-mongoid` (was `database_cleaner`).
- The gemspec `homepage` points to this fork.
- README converted from `README.rdoc` to `README.md` and rewritten for the maintained fork (branches, the
  optimized schema versus upstream, supported versions, usage checked against `lib/`, known issues); history
  moved to this file.

### Removed
- Travis CI configuration.
- The MongoMapper test harness and `mongo_mapper` development dependency (MongoMapper cannot be installed next
  to current Mongoid). The MongoMapper code paths in `lib/` remain but are untested and unsupported.

## [0.4.2] - 2016-04-25
### Added
- Cached counters `followers_cached_count` (followed models) and `followees_cached_count` (followers),
  maintained by the new runtime dependency `mongoid_magic_counter_cache >= 1.1.1`.
- Index `{followable_id, following_type, created_at}` on `Follow`; index declarations work on Mongoid 2, 3
  and 4.

### Changed
- `Follow` validates the presence of `followable` and `following`.

### Removed
- `bson_ext` development dependency.

## [0.4.1] - 2014-03-28
### Added
- Unique index `{following_id, followable_id, following_type, followable_type}` on `Follow`.

## [0.4.0] - 2014-03-27
First DOGOnews version, with a storage schema that is incompatible with upstream.

### Changed
- One `Follow` document per relationship, with polymorphic `followable` / `following` references stored as
  `BSON::ObjectId`s (indexed); the string `f_id` / `f_type` fields are gone. Followers and followees are loaded
  through these relations.
- `Follow` has `created_at` / `updated_at` (`Mongoid::Timestamps`).

### Fixed
- Destroying a followed or following document left its `Follow` documents behind (upstream issue #9).

## [0.3.2] - 2012-08-31
### Changed
- API reorganized into `Mongo::Followable::Followed`, `Mongo::Followable::Follower` and the optional
  `Mongo::Followable::History` modules (replacing `Mongo::Followable` / `Mongo::Follower` and the
  `config.mongo_followable` options); followers and followees are rebuilt with one query per type.

### Removed
- Authorization (`set_authorization` / `unset_authorization`, the `cannot_follow` / `cannot_followed` fields).

## [0.3.0] - 2012-05-31
### Added
- `config.mongo_followable = { authorization: false, history: false }` (Railtie): the authorization and
  history fields and methods are only defined when enabled.

## [0.2.5] - 2012-03-23
### Added
- `followed?` and `following?`.

### Changed
- `with_max_*` / `with_min_*` class methods are defined explicitly instead of through `method_missing`;
  `lib/` is only loaded when Mongoid or MongoMapper is present.

## [0.2.4] - 2012-03-06
### Fixed
- Model names with underscores or capitals (`child_user`, `ChildUser`) in type arguments and stored types
  (upstream issue #1).

## [0.2.3] - 2012-02-15
### Added
- `follow`, `unfollow` and `unfollowed` accept a block that selects which of the given models to act on.

## [0.2.2] - 2012-02-02
No changes besides the version.

## [0.2.1] - 2012-01-31
### Added
- `unfollow_all`, `unfollowed` and `unfollowed_all`.

## [0.2.0] - 2011-11-06
### Added
- Initial release by Jie Fan: following for Mongoid and MongoMapper documents.

[Unreleased]: https://github.com/joe1chen/mongo_followable/compare/v0.5.0...HEAD
[0.5.0]: https://github.com/joe1chen/mongo_followable/compare/v0.4.2...v0.5.0
[0.4.2]: https://github.com/joe1chen/mongo_followable/compare/v0.4.1...v0.4.2
[0.4.1]: https://github.com/joe1chen/mongo_followable/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/joe1chen/mongo_followable/compare/v0.3.2...v0.4.0
[0.3.2]: https://github.com/joe1chen/mongo_followable/compare/v0.3.0...v0.3.2
[0.3.0]: https://github.com/joe1chen/mongo_followable/compare/v0.2.5...v0.3.0
[0.2.5]: https://github.com/joe1chen/mongo_followable/compare/v0.2.4...v0.2.5
[0.2.4]: https://github.com/joe1chen/mongo_followable/compare/v0.2.3...v0.2.4
[0.2.3]: https://github.com/joe1chen/mongo_followable/compare/v0.2.2...v0.2.3
[0.2.2]: https://github.com/joe1chen/mongo_followable/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/joe1chen/mongo_followable/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/joe1chen/mongo_followable/releases/tag/v0.2.0
