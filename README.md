# mongo_followable

[![CI RSpec Test](https://github.com/joe1chen/mongo_followable/actions/workflows/test.yml/badge.svg?branch=master)](https://github.com/joe1chen/mongo_followable/actions/workflows/test.yml)

Follow / unfollow between **Mongoid** documents (users following users, users following groups, ...). Each
follow relationship is a single `Follow` document with polymorphic references to both sides; follower and
followee counts are also cached on the documents themselves.

This is the [DOGOnews](https://www.dogonews.com)-maintained fork of
[lastomato/mongo_followable](https://github.com/lastomato/mongo_followable) (upstream has been inactive since
2012). It is kept working on current Ruby, Rails, Mongoid and MongoDB versions, and it uses a different,
**incompatible storage schema** from upstream (see below).

## Branches: `master` and `integration`

Pin a **release tag** (see Installation); releases are cut from `master`. The fork's optimized follow schema was
developed on the `integration` branch (2014) and merged into `master` in 2021; since then `master` has only gained
CI/test changes. `integration` is a legacy alias that is fast-forwarded to `master`, so apps that still pin
`branch: 'integration'` get exactly the same code; it will be retired once the apps pin a tag.

### The optimized schema (vs upstream)

Upstream stores **two** documents per relationship (one under the followee, one under the follower), each with
string `f_id` / `f_type` fields, and rebuilds followers with an extra query per type. This fork
(commits `1475df1`, `ab6f12f`, `ba6af63`, `d8d041b`):

- stores **one** `Follow` document per relationship: `followable_id`/`followable_type` (who is followed) and
  `following_id`/`following_type` (who follows), as real `BSON::ObjectId`s via polymorphic `belongs_to`; the
  `f_id`/`f_type` fields are gone;
- adds `created_at`/`updated_at` (`Mongoid::Timestamps`) to `Follow`;
- caches counts on the documents: `followers_cached_count` on followed models and `followees_cached_count` on
  followers (via [mongoid_magic_counter_cache](https://github.com/jah2488/mongoid-magic-counter-cache));
- declares indexes: unique `{following_id, followable_id, following_type, followable_type}`,
  `{followable_id, following_type, created_at}`, plus the polymorphic reference indexes;
- loads followers/followees through the `following`/`followable` relations, and cleans up `Follow` documents when
  either side is destroyed (`dependent: :destroy`).

Data written by upstream mongo_followable cannot be read by this fork without a migration.

## Supported versions

Tested on every push by the [GitHub Actions matrix](https://github.com/joe1chen/mongo_followable/actions/workflows/test.yml)
([workflow](.github/workflows/test.yml)):

| Ruby | Rails | Mongoid | MongoDB |
|---|---|---|---|
| 2.7 | 6.1 | 7.5 | 6.0 |
| 3.0 | 6.1 | 8.0 | 6.0 |
| 3.1 | 7.0 | 8.1 | 7.0 |
| 3.2 | 7.1 | 8.1 | 7.0 |
| 3.2 | 7.2 | 9.0 | 7.0 |
| 3.3 | 7.2 | 9.0 | 8.0 |
| 3.4 | 8.0 | 9.0 | 8.0 |
| 2.7 | 6.1 | 7.5 (driver 2.26) | 8.0 |

Only Mongoid is tested. `lib/` still contains MongoMapper code paths from upstream, but they are untested and
unsupported.

## Installation

This fork is not published to RubyGems; install it from GitHub, pinned to a release tag
([releases](https://github.com/joe1chen/mongo_followable/releases)):

```ruby
# Gemfile
gem 'mongo_followable', github: 'joe1chen/mongo_followable', tag: 'v0.5.0'
```

`branch: 'integration'` is a legacy alias that tracks `master`; it will be retired once the apps pin a tag.

Then `bundle install`. Create the `Follow` indexes once (e.g. `rake db:mongoid:create_indexes` in Rails, or
`Follow.create_indexes`).

## Usage

### Make models followable / followers

```ruby
class User
  include Mongoid::Document
  include Mongo::Followable::Followed   # can be followed
  include Mongo::Followable::Follower   # can follow
  include Mongo::Followable::History    # optional: follow_history / followed_history arrays
end

class Group
  include Mongoid::Document
  include Mongo::Followable::Followed
  include Mongo::Followable::History
end
```

`Followed` adds `has_many :followers` (`Follow` documents) and a `followers_cached_count` field; `Follower` adds
`has_many :followees` (`Follow` documents) and a `followees_cached_count` field. `History` adds
`follow_history` / `followed_history` fields to whichever of the two modules is included.

### Follow and unfollow

```ruby
current_user.follow(@group)
current_user.follow(@user1, @user2, @group)            # several at once
current_user.follow(u1, u2, u3) { |u| u.active? }      # only those the block accepts

current_user.unfollow(@group)
current_user.unfollow(u1, u2) { |u| u.followee_of?(current_user) }
current_user.unfollow_all

@group.unfollowed(current_user)                        # from the followed side
@group.unfollowed_all
```

Following yourself, or following something twice, is a no-op.

### Query relationships

```ruby
current_user.follower_of?(@group)      # => true / false
@group.followee_of?(current_user)
current_user.following?                # follows anything?
@group.followed?                       # followed by anyone?

@group.all_followers                   # => [user, ...]   (documents, not Follow records)
current_user.all_followees             # => [group, user, ...]
@group.followers_by_type("user")       # "user", "User", "child_user" and "ChildUser" all work
current_user.followees_by_type("group")
User.followers_of(@group)              # same as @group.followers_by_type("User")
Group.followees_of(current_user)       # same as current_user.followees_by_type("Group")

@group.followers_count                 # counts Follow documents
current_user.followees_count
@group.followers_count_by_type("user")
current_user.followees_count_by_type("group")
@group.followers_cached_count          # cached counter fields, no query
current_user.followees_cached_count

current_user.common_followees?(@other_user)
current_user.common_followees_with(@other_user)   # => [...]
@group.common_followers?(@other_group)
@group.common_followers_with(@other_group)

User.with_max_followees
User.with_max_followees_by_type('group')
Group.with_max_followers
Group.with_max_followers_by_type('user')
```

Note that `followers` / `followees` themselves return `Follow` documents; use `all_followers` / `all_followees`
to get the models (e.g. as `receivers:` for [streama](https://github.com/joe1chen/streama)'s `publish_activity`).

### Follow history (with `Mongo::Followable::History`)

```ruby
current_user.ever_follow               # => [...] everything ever followed
@group.ever_followed                   # => [...] everyone who ever followed
current_user.ever_follow?(@group)
@group.ever_followed?(current_user)

current_user.clear_follow_history!
@group.clear_followed_histroy!         # sic, see Known issues
current_user.clear_history!            # both
```

To drop the history fields entirely: `User.all.each { |u| u.unset(:follow_history) }`.

## Development

```bash
# needs a MongoDB on localhost:27017 (e.g. docker run -p 27017:27017 mongo:8.0)
MONGOID_VERSION=9.0 RAILS_VERSION=8.0 bundle install
MONGOID_VERSION=9.0 RAILS_VERSION=8.0 bundle exec rspec spec
```

`MONGOID_VERSION` and `RAILS_VERSION` select the versions in the `Gemfile` (defaults: Mongoid 7.5, Rails 6.1).
To add a combination to CI, add a row to `matrix.include` in `.github/workflows/test.yml`.

## Known issues

- `with_min_followers`, `with_min_followers_by_type`, `with_min_followees` and `with_min_followees_by_type` use
  the **maximum** count (`follow_array[-1]`), so they return the same result as the `with_max_*` variants. They
  also load every document of the class into memory, as do the `with_max_*` methods.
- The history method is spelled `clear_followed_histroy!` (`clear_history!` calls it correctly).
- `followers_count` / `followees_count` query the `follows` collection; `*_cached_count` are maintained by
  mongoid_magic_counter_cache on create/destroy of `Follow` documents only (not on `delete`/bulk removal).
- `Follow` declares an unused `fixed_ts` field.
- `Mongo::Authorization` and `Mongo::Confirmation` (`lib/mongo_followable/features`) are empty placeholders.
- MongoMapper support is untested.

## History

Jie Fan's original (2011, Mongoid and MongoMapper) reached 0.3.2 on RubyGems (2012) and was continued by
DOGOnews in this fork: 0.4.0–0.4.2 (2014–2016, on the `integration` branch: one `Follow` document per
relationship, timestamps, cached counters, indexes; merged into `master` in 2021), then 0.5.0 (2026: tested on
Mongoid 7.5–9.x with current Ruby/Rails/MongoDB, no changes to `lib/` or the stored schema).
See [CHANGELOG.md](CHANGELOG.md).

## Thanks

Thanks to the authors of [acts_as_followable](https://github.com/xpepermint/acts_as_followable) and
[voteable_mongo](https://github.com/vinova/voteable_mongo).

## Credits

- Jie Fan — original author
- [Contributors](https://github.com/joe1chen/mongo_followable/graphs/contributors)

Copyright (c) 2011 Jie Fan. Licensed under the MIT license, see [LICENSE.txt](LICENSE.txt).
