# Medusa EarthShape - AI Coding Agent Instructions

## Project Overview
Medusa is a **Rails 8.1.1** scientific sample management system built for geological/earth science research, currently running **Ruby 3.4.8**. It manages hierarchical collections of physical samples (stones), their containers (boxes), sampling locations (places), and analytical data (analyses with chemistry measurements). The system includes IGSN (International Geo Sample Number) registration capabilities and outputs data in various formats including PML (Phml Markup Language) and BibTeX.

**⚠️ Important**: The application has been successfully upgraded from Rails 4.0.2 to Rails 8.1.1 and Ruby 2.1.10 to Ruby 3.4.8. Currently at **Ruby 3.4.8 + Rails 8.1.1**. See `UPGRADE-PLAN.md` for upgrade history and next steps.

## Core Domain Architecture

### Central Resource Hierarchy
The application revolves around a hierarchical structure with bidirectional relationships:

```
Collection (sampling campaign)
  └─ Place (sampling location with coordinates)
       └─ Box (container hierarchy, self-referential tree)
            └─ Stone (sample, self-referential tree)
                 └─ Analysis (measurement session)
                      └─ Chemistry (individual measurements)
                      └─ Spot (image coordinates for analysis point)
```

### Key Model Patterns

**HasRecordProperty Concern**: Every major resource includes `HasRecordProperty` which adds:
- `record_property` polymorphic association for permissions and global_id
- Global ID generation: timestamp-based unique identifiers (format: `YYYYMMDDHHMMSS-XXX-RRR`)
- User/group-based access control (owner/group/guest read/write permissions)
- `.readables(user)` scope for filtering accessible records
- Automatic delegation of `global_id`, `published_at`, `user_id`, `group_id`

**Recursive Trees**: `Stone` and `Box` use self-referential `parent_id`/`children` relationships with:
- `HasRecursive` concern providing `.descendants`, `.ancestors`, `.self_and_descendants`
- Custom `.blood_path` and `.box_path` methods for displaying hierarchies
- Validations preventing circular references (`parent_id_cannot_self_children`)

**Polymorphic Attachments**:
- `AttachmentFile`: Paperclip-managed files attached to multiple resource types via `Attaching` join model
- `Referring`: Links `Bib` (bibliography) to any `referable` resource
- `Spot`: Records x/y coordinates on images, linked via `target_uid` (global_id)

## Critical Conventions

### Language & Documentation

**English Only**: All code, comments, documentation, commit messages, and variable names MUST be written in English. This is a strict project requirement to maintain consistency and accessibility.

### Controllers

**Nested Resources Pattern**: Resources can be managed as children of parents (e.g., `/stones/:stone_id/analyses`):
```ruby
# Location: app/controllers/nested_resources/
# Pattern: Dynamic parent lookup via params[:parent_resource]
def find_resource
  resource_class = params[:parent_resource].camelize.constantize
  @parent = resource_class.find(params["#{params[:parent_resource]}_id"])
end
```

**Global ID Linking**: Resources support linking via `link_by_global_id` action:
```ruby
# Accept global_id param, join records through associations
def link_by_global_id
  resource = Model.joins(:record_property).where(record_properties: {global_id: params[:global_id]})
  @parent.association << resource
end
```

**Bundle Operations**: Many resources support batch editing via `bundle_edit` and `bundle_update` actions for modifying multiple records simultaneously.

### Authorization & Authentication

- **Devise 4.9.4** for user authentication (supports HTTP Basic Auth for API calls)
  - ⚠️ Uses Devise 4.x parameter sanitizer API: `.permit(keys: [...])` instead of `.for(:sign_up)`
- **CanCan** (Ability class): Admin users can manage all; other users filtered by `record_property` permissions
- Current user stored in `User.current` (thread-local) for audit trails
- `load_and_authorize_resource` used in all resource controllers

### Database

- **PostgreSQL** with `plpgsql` extensions
- Tables prefixed conventionally (no namespace)
- `acts_as_taggable_on` for flexible categorization
- `with_recursive` gem for tree queries on hierarchical models

### Decorator Pattern

- **Draper** decorators for all models (see `app/decorators/`)
- Used primarily in JSON responses: `datum.decorate.as_json`
- Presentation logic isolated from models

### Testing

- **RSpec-Rails 5.1.2** with FactoryGirl fixtures (Rails 6.1 compatible)
- **Guard** with Spring for auto-running tests on file changes
- **Capybara + Poltergeist** for integration tests (request specs)
- Run via: `bundle exec guard` (watches files) or `bundle exec rspec`

**⚠️ Known Test Coverage Gaps** (see `TEST-GAP-ANALYSIS.md`):
- Request specs use Warden bypass (skip Devise controllers)
- No feature tests for form submissions
- No asset precompilation tests
- Manual browser testing required to catch integration issues

**Critical Testing Notes**:
- **RSpec-Rails 5.1+**: Required for Rails 6.1 compatibility
- **Rails 6.1**: Uses Classic autoloader (Zeitwerk temporarily disabled for compatibility)
- Test pass rate does NOT guarantee production readiness
- Feature tests are missing - add before major upgrades
- Virtual attributes for forms (`*_global_id` setters) are NOT tested by existing suite
- Always perform manual browser testing after significant changes

## Specialized Features

### Scientific Data Export

**PML Output**: Analyses and related data export to XML format via:
```ruby
# Instance: analysis.to_pml
# Bulk: Analysis.to_castemls([analysis1, analysis2])
```

**BibTeX Generation**: Resources generate BibTeX entries via `.to_bibtex` with DREAM repository URLs.

**CSV Import/Export**: 
- Analyses import via `Analysis.import_csv(file)` with custom column mapping
- Stones have complex CSV structure including collection/place/box metadata (see `Stone.csvlabels`)

### Dynamic Chemistry Attributes

`Analysis` uses `method_missing` for dynamic measurement item handling:
```ruby
# Set: analysis.Fe_in_ppm = 150
# Get: analysis.Fe_in_ppm
# Error: analysis.Fe_error = 5
```
Based on `MeasurementItem.nickname` lookups, auto-creates `Chemistry` records with unit conversions via Alchemist gem.

### IGSN Registration

Admin users can register samples with IGSN authorities via `StonesController#igsn_register` - generates metadata for parent sample hierarchy.

## Development Workflow

### Docker Development (Recommended)

**Quick Start:**
```bash
docker compose up -d        # Start application
docker compose logs -f web  # View logs
docker compose down         # Stop application
```

**Rails Console:**
```bash
docker compose exec web bundle exec rails console
```

**Database Operations:**
```bash
docker compose exec web bundle exec rake db:migrate
docker compose exec web bundle exec rake db:reset
docker compose exec db psql -U medusa -d medusa_development
```

See `DOCKER.md` for comprehensive Docker documentation. On Windows, see `DOCKER-WINDOWS.md` for PowerShell-specific commands.

### Native Development

#### Setup
```bash
bundle install
# Configure config/database.yml and config/application.yml from .example files
bundle exec rake db:setup
```

### Running Tests
```bash
bundle exec guard           # Auto-run tests on file changes
bundle exec rspec spec/models/stone_spec.rb  # Single file
```

### Deployment
- **Capistrano 3**: `cap production deploy`
- **Unicorn** application server
- Config files symlinked: `config/application.yml`, `config/database.yml`
- Assets precompiled with custom `rails_relative_url_root` for subdirectory deployment

### Common Rake Tasks
```bash
rake db:dump_records:latex   # Export records in LaTeX format
rake db:dump_records:bib     # Export as BibTeX
rake db:load                 # Database backup load
rake update_record_properties  # Sync names/timestamps to record_properties
```

## Key Files & Locations

- **Routes**: `config/routes.rb` - uses `concerns` for shared route patterns (`:bundleable`, `:reportable`, `:igsnable`)
- **Permissions**: `app/models/ability.rb` - CanCan authorization rules
- **Model Concerns**: `app/models/concerns/` - shared behaviors (8 modules including Ransackable)
- **Nested Controllers**: `app/controllers/nested_resources/` - parent-child resource management
- **Initializers**: `config/initializers/` - Paperclip, Devise, custom patches

**Ransackable Concern** (Ransack 4.0+ Security):
- Located: `app/models/concerns/ransackable.rb`
- Purpose: Allowlist searchable/sortable attributes for Ransack gem (security requirement since v4.0)
- Usage: `include Ransackable` in models (29 models use this)
- Auto-allowlists: All column names except sensitive fields (passwords, tokens)
- Auto-allowlists: All associations for searching
- Override: Can be customized per model by overriding `ransackable_attributes` or `ransackable_associations`

## Important Constraints

- Always use `.readables(current_user)` scope when querying protected resources
- Global IDs are unique system-wide, used for cross-resource linking
- Parent-child associations must validate against circular references
- Polymorphic associations (`datum`, `referable`, `attachable`) require explicit type handling
- CSV imports expect specific column orders (see model `csvlabels` methods)

**Virtual Attributes for Global ID Forms**:
Several models implement virtual `*_global_id` getters/setters for form-based relationships:
- `Place#parent_global_id` - links to parent Place
- `Box#parent_global_id` - links to parent Box  
- `Stone#parent_global_id`, `#place_global_id`, `#box_global_id`, `#collection_global_id` - links to parent Stone, Place, Box, Collection
- These setters look up `RecordProperty` by global_id and set the foreign key (`parent_id`, `place_id`, etc.)
- Required for HTML forms that use global_id text inputs instead of dropdowns

## API Notes

REST API available for all resources:
- Responds to `.html`, `.xml`, `.json`, `.pml` (analyses only)
- HTTP Basic Auth supported (bypasses CSRF for non-browser clients)
- Global IDs used as query parameters for linking operations
- Pagination via Kaminari gem

---

## Recent Major Changes (November 2025 Upgrades)

### Phase 1: Rails 4.0.2 → 4.2.11.3 + Ruby 2.1.10 → 2.3.8 (Completed)

Key changes that affect development:
1. **Devise 4.x API**: Parameter sanitizer changed from `.for()` to `.permit(keys: [...])`
2. **Sass-Rails 5.x**: Asset helpers use `asset-url("file")` instead of `asset-url("file", type)`
3. **Rails 4.2**: `secrets.yml` required (replaces secret_token)
4. **View Helpers**: `link_to_function` removed - use `link_to ... onclick:` instead
5. **Dynamic Finders**: Deprecated - use `.where()` instead of `.find_all_by_*`
6. **Strong Parameters**: Array elements require explicit `.permit()` for each element
7. **Virtual Attributes**: Added 7 `*_global_id` methods across Place, Box, Stone models

See `UPGRADE-RAILS42-SUMMARY.md` for complete list of changes.

### Phase 2: Ruby 2.3.8 → 2.5.9 (Completed 11. November 2025)

**Status**: ✅ Successfully completed through Ruby 2.4.10 → 2.5.9

Key changes:
1. **JavaScript Runtime**: therubyracer → mini_racer (Ruby 2.4+ compatible)
2. **Fixnum/Bignum**: Unified to `Integer` in Ruby 2.4 (no code changes needed)
3. **Native Extensions**: All 21 gems with native extensions recompiled for Ruby 2.4+
4. **Test Stability**: Maintained 99.86% pass rate through upgrade

**Test Results**: 1399/1401 passing, 2 known flaky group sorting tests

**Docker**: Now uses `FROM ruby:2.5.9` base image

### Phase 3: Rails 5.0 → 5.1 → 5.2 → 6.0 → 6.1 (Completed 17. November 2025)

**Status**: ✅ Successfully completed, all tests passing (100%), CI/CD green

**Rails 5.0.7.2** (completed):
- ActionController::Parameters stricter validations
- ApplicationRecord base class for models
- belongs_to required by default
- Halted callback chains on `false` returns

**Rails 5.1.7** (completed):
- Form helpers updated (form_for → form_with)
- System tests infrastructure added
- Encrypted secrets support
- Parameterized mailers

**Rails 5.2.8.1** (completed):
- ActiveStorage support
- Credentials management
- Redis cache store support
- Bootsnap integration
- Place model initialize compatibility fix (382 tests fixed)

**Rails 6.0.6.1** (completed):
- **Zeitwerk Autoloader**: Temporarily using Classic mode for compatibility
- **Cookie Serializer**: Changed from `:json` to `:marshal` for Devise compatibility
- **RSpec-Rails 4.0**: Required for Rails 6.0 support
- **ActiveRecord Changes**: `.exists` → `.exists?`, correlated subqueries rewritten
- **PML MIME Type**: Registered as `application/xml` for respond_with compatibility
- **Renderer Signatures**: Updated for Rails 6.0 API (accepts options parameter)
- **Logger Compatibility**: Explicit `require 'logger'` for Ruby 2.5 + Rails 6.0
- **ActionMailbox/ActionText**: New Rails 6.0 features available

**Rails 6.1.7.10** (completed 17. November 2025):
- **Acts-as-Taggable-On**: Upgraded to 9.0.1 for Rails 6.1 compatibility (Ruby 2.5+)
- **File Fixtures**: `fixture_file_upload` replaced with `Rack::Test::UploadedFile`
- **ActiveStorage Migrations**: Two new migrations for variant tracking
- **Framework Defaults**: `config.load_defaults 6.1` activated
- **Geonames API**: Added coordinate validation and error handling for flaky external API tests
- **Classic Autoloader**: Still using Classic mode (Zeitwerk migration deferred)

**Test Results**: 1318/1318 passing (100%), 13 pending, runtime ~3-4min

### Phase 4: Ruby 2.5.9 → 2.6.10 → 2.7.8 → 3.0.6 (Completed 27. November 2025)

**Status**: ✅ Successfully completed, 100% tests passing

**Ruby 2.6.10** (completed 18. November 2025):
- Mini_racer upgrade for Ruby 2.6+ compatibility
- All native extensions recompiled
- No code changes required
- PhantomJS removed (not available in Debian Bullseye)

**Ruby 2.7.8** (completed 19. November 2025):
- **RSpec-Rails**: Upgraded 4.0.2 → 5.1.2 (Rails 6.1 requirement)
- **Ransack 4.0.0 Breaking Changes** (MAJOR):
  - API: `.search()` → `.ransack()` (30 controllers updated)
  - Sorts: `sorts = "string"` → `sorts = ["string"]` (29 controllers updated)
  - Security: Added `ransackable_attributes` allowlisting (29 models updated)
  - Created `Ransackable` concern for centralized security policy
- **Docker**: Added entrypoint with `bundle check || bundle install` for volume mount compatibility
- **pg gem**: 1.5.9 → 1.6.2 (Ruby 2.7 + Rails 6.1 compatibility)
- **mini_racer**: 0.4.0 → 0.6.3 (Ruby 2.7 support)

**Ruby 3.0.6** (completed 27. November 2025):
- **mime-types**: 2.99.3 → 3.7.0 (Ruby 3.0 numbered params `_1`, `_2`, `_3` reserved)
- **rest-client**: 1.8.0 → 2.1.0 (for mime-types 3.x compatibility)
- **datacite_doi_ify**: Disabled (requires rest-client 1.x, needs Ruby 3.0 compatible fork)
- **Paperclip**: URI.escape patch was needed (later replaced by kt-paperclip migration)
- **Test Results**: 1380/1380 passing (100%), 13 pending

**Ruby 3.1.6** (completed 27. November 2025):
- **nokogiri**: 1.10.10 → 1.16.x (Ruby 3.1 requires nokogiri 1.13+)
- **loofah**: 2.3.1 → 2.22.x (for nokogiri 1.16 compatibility)
- **Test Results**: 1380/1380 passing (100%), 13 pending

**Ruby 3.2.6** (completed 27. November 2025):
- **File.exists?** → **File.exist?**: Fixed in 6 files (removed in Ruby 3.2)
  - `app/models/attachment_file.rb`
  - `config/unicorn/*.rb`
  - `config/deploy/unicorn/production.rb.erb`
- **Test Results**: 1380/1380 passing (100%), 13 pending

**Ruby 3.3.10** (completed 28. November 2025):
- **Prism Parser**: New default parser (portable, error-tolerant, maintainable)
- **YJIT Improvements**: ~3x faster than interpreter, better memory usage
- **M:N Thread Scheduler**: Improved thread management for multi-core systems
- **Lrama Parser Generator**: Replaces Bison for grammar parsing
- **No Breaking Changes**: `it` block parameter deprecation warning (Ruby 3.4 change)
- **No Code Changes Required**: All existing code compatible
- **Test Results**: 1335/1335 passing (100%), 14 pending

**Ruby 3.4.7** (completed 2. December 2025):
- **`it` Block Parameter**: New shorthand for block parameters (`ary.map { it.upcase }`)
- **Prism Default Parser**: Prism is now the default parser (previously optional)
- **Happy Eyeballs v2**: Improved network connectivity (RFC 8305)
- **Modular GC**: Garbage collector can be loaded dynamically
- **Default Gems → Bundled Gems** (BREAKING):
  - `csv`, `bigdecimal`, `mutex_m`, `base64`, `drb` must now be in Gemfile
  - Added these 5 gems to Gemfile explicitly
- **Frozen String Literal Warning**: Deprecation warnings when mutating strings without `# frozen_string_literal: true`
- **URI Parser**: Now RFC 3986 compliant (was RFC 2396)
- **Test Results**: 1335/1335 passing (100%), 14 pending

**Ruby 3.4.8** (completed 17. December 2025):
- **Patch Release**: Bug fixes and security patches only
- **No Breaking Changes**: All existing code compatible
- **No Code Changes Required**: Direct drop-in upgrade from 3.4.7
- **Docker Image**: Using `ruby:3.4` tag (will automatically update when 3.4.8 image is published)
- **Gemfile**: Updated to `ruby '>= 3.4.8', '< 3.5'`
- **Test Results**: 1385/1385 passing (100%), 10 pending

### Phase 5: Rails 7.0 (completed 28. November 2025)

**Rails 7.0.10** (completed 28. November 2025):
- **Zeitwerk Autoloader**: Classic autoloader removed, Zeitwerk is only option
- **Sprockets 4.0**: Added `app/assets/config/manifest.js`
- **responders gem**: Added for `respond_with` (removed from Rails core in 4.2)
- **Open Redirect Protection**: Disabled for legacy `request.referer` usage
  - `config.action_controller.raise_on_open_redirects = false`
- **Alchemist Initializer**: Wrapped in `Rails.application.config.to_prepare`
- **Gem Updates**:
  - `rails`: 6.1.7.10 → 7.0.10
  - `zeitwerk`: 2.3.0 → 2.6+
  - `sass-rails`: 5.x → 6.0
  - `coffee-rails`: 4.x → 5.0
  - `cancancan`: 3.0 → 3.5
  - `acts-as-taggable-on`: 9.0 → 10.0
  - `responders`: NEW 3.1+ (for respond_with)
- **Test Results**: 1380/1380 passing (100%), 13 pending

### Phase 6: Rails 7.1 (completed 28. November 2025)

**Rails 7.1.6** (completed 28. November 2025):
- **Rack 3 Compatibility**: Puma 5.6 → 6.6.1 (Puma 5 is not compatible with Rack 3)
- **Serialize API Change**: `serialize :field, Array` → `serialize :field, type: Array, coder: YAML`
- **RSpec-Rails 6.x**: Required for Rails 7.1 (5.x not compatible with ActionView changes)
- **PostgreSQL Decoder Fix**: Disabled for Rails 7.0+ (no longer needed)
- **Gem Updates**:
  - `rails`: 7.0.10 → 7.1.6
  - `puma`: 5.6 → 6.6.1
  - `rspec-rails`: 5.1.2 → 6.1.5
- **Test Results**: 1397/1397 passing (100%), 14 pending

**Deprecation Warnings** (non-critical):
- Thinreports layout format outdated (Editor 0.8 or lower)
- ✅ RSpec `:should` syntax → `:expect` syntax (fixed 28. November 2025)

**Ransack 4.0 Migration Details**:
All searchable models now include the `Ransackable` concern which:
- Auto-allowlists all column names except sensitive fields (passwords, tokens)
- Auto-allowlists all associations for searching
- Can be overridden per model for custom security policies

### Phase 7: Rails 7.2 (completed 28. November 2025)

**Rails 7.2.3** (completed 28. November 2025):
- **FactoryGirl → FactoryBot Migration** (MAJOR):
  - `factory_girl_rails` incompatible with Rails 7.2's ActiveSupport changes
  - Error: `NoMethodError: private method 'warn' called for ActiveSupport::Deprecation:Class`
  - Solution: Migrate to `factory_bot_rails` 6.5.1
  - 550+ occurrences of `FactoryGirl` replaced with `FactoryBot` in spec/
- **FactoryBot 5.0+ Syntax** (MAJOR):
  - Static attribute syntax removed: `name "value"` → `name { "value" }`
  - All 28 factory files updated in `spec/factories/`
- **acts-as-taggable-on**: 10.0 → 13.0.0 (Rails 7.2 compatibility)
- **RSpec fixture_paths**: `fixture_path` → `fixture_paths` (Rails 7.1 deprecation fixed)
- **RSpec :should syntax**: `.stub()` → `allow().to receive()` (fixed 28. November 2025)
- **Gem Updates**:
  - `rails`: 7.1.6 → 7.2.3
  - `acts-as-taggable-on`: 10.0 → 13.0.0
  - `factory_bot_rails`: NEW 6.5.1 (replaces factory_girl_rails)
- **File Renames**:
  - `spec/support/factory_girl.rb` → `spec/support/factory_bot.rb`
- **Test Results**: 1397/1397 passing (100%), 14 pending

### Phase 8: Rails 8.0 (completed 2. December 2025)

**Rails 8.0.4** (completed 2. December 2025):
- **sprockets-rails**: Must be explicitly added to Gemfile (no longer default in Rails 8.0)
- **Deferred Route Drawing**: Rails 8.0 loads routes lazily
  - Breaks Devise test helpers ("Could not find a valid mapping for User")
  - Workaround: Add `Rails.application.reload_routes_unless_loaded` in `config.before(:each, type: :controller)`
  - See: https://github.com/heartcombo/devise/issues/5705
- **config.load_defaults**: Updated from 7.2 to 8.0
- **No Code Changes Required**: All existing code compatible
- **Gem Updates**:
  - `rails`: 7.2.3 → 8.0.4
  - `sprockets-rails`: NEW (explicitly added)
- **Test Results**: 1347/1347 passing (100%), 10 pending

**Rails 8.0 New Features** (available but not yet adopted):
- Kamal 2 (container deployment - keeping Capistrano)
- Thruster (proxy for Puma)
- Solid Queue/Cache/Cable (Redis alternatives)
- Propshaft (asset pipeline - keeping Sprockets)
- `params.expect()` API (optional, `params.require().permit()` still works)

**Paperclip Status**: Migrated to `kt-paperclip` 7.2.2 (maintained fork, Rails 7.x/8.x + Ruby 3.x compatible)
- URI.escape patch removed (kt-paperclip handles this internally)
- No ActiveStorage migration needed - kt-paperclip is actively maintained

**Docker**: Now uses `FROM ruby:3.4.8` base image

### Phase 9: Rails 8.1 (completed 2. December 2025)

**Rails 8.1.1** (completed 2. December 2025):
- **Path-Relative Redirect Protection** (BREAKING CHANGE):
  - Rails 8.1 defaults `config.action_controller.action_on_path_relative_redirect` to `:raise`
  - This broke 93 tests that mocked `request.referer` with relative paths like `"where_i_came_from"`
  - Fix: Added `config.action_controller.action_on_path_relative_redirect = :log` to `config/application.rb`
  - In production, `request.referer` always provides absolute URLs, so this is test-only
- **config.load_defaults**: Updated from 8.0 to 8.1
- **No Code Changes Required**: All existing code compatible (after config fix)
- **Gem Updates**:
  - `rails`: 8.0.4 → 8.1.1
- **Test Results**: 1347/1347 passing (100%), 10 pending

**Rails 8.1 New Features** (available but not yet adopted):
- Active Job Continuations (for long-running jobs with restart capability)
- Structured Event Reporting (`Rails.event.notify`)
- Local CI (`bin/ci` with `config/ci.rb` DSL)
- Markdown Rendering (`format.md` and `render markdown:`)
- Deprecated Associations (`has_many :posts, deprecated: true`)
- schema.rb columns now alphabetically sorted (reduces merge conflicts)

### Phase 10: Gem Dependency Updates (15. December 2025)

**Routine Dependency Update** (completed 15. December 2025):
- All gems updated to latest compatible versions
- No breaking changes, all tests passing
- **Major Gem Updates**:
  - `mini_racer`: 0.6.4 → 0.19.1 (JavaScript V8 runtime, major version upgrade)
  - `rubyzip`: 2.4.1 → 3.2.2 (ZIP file handling, major version upgrade)
  - `exception_notification`: 4.6.0 → 5.0.1 (error notifications, major version upgrade)
  - `rqrcode`: 2.2.0 → 3.1.1 (QR code generation, major version upgrade)
  - `public_suffix`: 5.1.1 → 7.0.0 (domain parsing, major version upgrade)
  - `connection_pool`: 2.5.5 → 3.0.2 (connection pooling, major version upgrade)
  - `ransack`: 4.3.0 → 4.4.1 (search/filter)
  - `acts-as-taggable-on`: 13.0.0 → 14.0.0 (tagging system)
  - `draper`: 4.0.2 → 4.0.3 (decorators)
- **Minor Updates** (27+ gems):
  - `bigdecimal`, `csv`, `nokogiri`, `loofah`, `rails-html-sanitizer`
  - `puma`, `net-imap`, `net-smtp`, `net-pop`
  - `capybara`, `selenium-webdriver`, `regexp_parser`
  - And many more standard library updates
- **Test Results**: 1347/1347 passing (100%), 10 pending

---
*Last Updated: 2025-12-17 after Ruby 3.4.8 upgrade*
