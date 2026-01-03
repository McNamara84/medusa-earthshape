# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'ttfunk'
  spec.version       = '1.8.0'
  spec.summary       = 'TrueType and OpenType font library'
  spec.description   = 'TTFunk is a TrueType and OpenType font library written in pure Ruby.'
  spec.authors       = ['TTFunk contributors']
  spec.files         = Dir.glob('{lib}/**/*', File::FNM_DOTMATCH).reject { |f| File.directory?(f) } + %w[
    CHANGELOG.md
    COPYING
    GPLv2
    GPLv3
    LICENSE
    README.md
  ]
  spec.require_paths = ['lib']

  # Relaxed to allow bigdecimal 4.x (unblocks Ruby 3.4+/4.x setups).
  spec.add_dependency 'bigdecimal', '>= 3.1'
end
