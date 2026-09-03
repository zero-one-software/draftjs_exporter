# frozen_string_literal: true
require 'pathname'

ROOT_DIR = Pathname.new('.').expand_path(__dir__)
LIB_DIR = ROOT_DIR.join('lib')
SPEC_DIR = ROOT_DIR.join('spec')

$LOAD_PATH.push(LIB_DIR)
require 'draftjs_exporter/version'

Gem::Specification.new do |s|
  s.name                  = 'zo_draftjs_exporter'
  s.version               = DraftjsExporter::VERSION
  s.licenses              = ['MIT']
  s.summary               = 'Export Draft.js content state into HTML (Zero One fork)'
  s.description           = <<-EOS
Draft.js is a framework for building rich text editors. However, it does not support exporting documents at
HTML. This gem is designed to take the raw `ContentState` (output of `convertToRaw`) from Draft.js and convert
it to HTML using Ruby.

This is a Zero One fork of the `draftjs_exporter` gem, published separately as `zo_draftjs_exporter`. It adds
a `block_callback:` hook invoked after each block is rendered, and support for `className` entries in the
`style_map` so inline styles can emit CSS classes alongside inline `style` attributes. It keeps the upstream
`draftjs_exporter` require paths and `DraftjsExporter` namespace, so it cannot be installed alongside the
original gem.
EOS
  s.authors               = ['Theo Cushion', 'Zero One Software']
  s.email                 = 'hello@zero-one.io'
  s.homepage              = 'https://github.com/zero-one-software/draftjs_exporter'
  s.required_ruby_version = '>= 2.1.0'

  s.metadata = {
    'source_code_uri' => 'https://github.com/zero-one-software/draftjs_exporter',
    'upstream_repository_uri' => 'https://github.com/ignitionworks/draftjs_exporter'
  }

  s.files = [
    ROOT_DIR.join('*.md'),
    LIB_DIR.join('**/*.rb'),
    SPEC_DIR.join('**/*')
  ].flat_map { |p| Pathname.glob(p) }.map { |p| p.relative_path_from(ROOT_DIR).to_s }

  s.add_runtime_dependency 'nokogiri', '~> 1.6', '>= 1.6.0'

  s.add_development_dependency 'rspec', '~> 3.4', '>= 3.4.0'
  s.add_development_dependency 'rubocop', '~> 0.40', '>= 0.40.0'
  s.add_development_dependency 'codeclimate-test-reporter', '~> 0.5', '>= 0.5.0'
  s.add_development_dependency 'simplecov', '~> 0.11', '>= 0.11.0'
end
