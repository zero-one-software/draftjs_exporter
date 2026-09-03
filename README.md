# Draft.js Exporter (Zero One fork)

> **This is a Zero One fork of [`ignitionworks/draftjs_exporter`](https://github.com/ignitionworks/draftjs_exporter),
> published to RubyGems as [`zo_draftjs_exporter`](https://rubygems.org/gems/zo_draftjs_exporter).**
>
> It keeps the upstream `draftjs_exporter` require paths and `DraftjsExporter` namespace, so it is a drop-in
> replacement for the original gem — but for the same reason the two cannot be installed side by side.
> See [Fork changes](#fork-changes) for what differs from upstream.

```ruby
# Gemfile — note the `require:`, see Installation below
gem 'zo_draftjs_exporter', '~> 0.0.7', require: 'draftjs_exporter'
```

[Draft.js](https://facebook.github.io/draft-js/) is a framework for
building rich text editors. However, it does not support exporting
documents at HTML. This gem is designed to take the raw `ContentState`
(output of [`convertToRaw`](https://facebook.github.io/draft-js/docs/api-reference-data-conversion.html#converttoraw))
from Draft.js and convert it to HTML using Ruby.

## Installation

```ruby
# Gemfile
gem 'zo_draftjs_exporter', '~> 0.0.7', require: 'draftjs_exporter'
```

**The `require:` option is required.** The gem is published as `zo_draftjs_exporter`,
but to stay a drop-in replacement for upstream it still ships its code at
`lib/draftjs_exporter/` under the `DraftjsExporter` namespace. The package name and
the require path therefore differ, and Bundler auto-requires the *package* name by
default — `require 'zo_draftjs_exporter'` — which does not exist.

Worse, that failure is silent. Bundler only raises a missing-file `LoadError` when
the gem name contains a `-` it can retry as a `/`; `zo_draftjs_exporter` has none, so
the error is swallowed and the gem simply never loads. You find out later, somewhere
unrelated:

```
NameError: uninitialized constant DraftjsExporter::HTML
```

So if you omit `require:`, nothing appears to go wrong at boot. Set it.

Requiring by hand (outside Bundler) uses the same path:

```ruby
require 'draftjs_exporter'                      # => DraftjsExporter::HTML
```

Note that this loads `DraftjsExporter::HTML` only. Entity decorators are not pulled in
by the entry point, so require any you configure:

```ruby
require 'draftjs_exporter/entities/link'        # => DraftjsExporter::Entities::Link
```

Because the require paths and namespace are shared with upstream `draftjs_exporter`,
the two gems cannot be installed alongside each other — remove the original if it is
still in your `Gemfile`.

## Usage

```ruby
# Create configuration for entities and styles
config = {
  entity_decorators: {
    'LINK' => DraftjsExporter::Entities::Link.new(className: 'link')
  },
  block_map: {
    'header-one' => { element: 'h1' },
    'unordered-list-item' => {
      element: 'li',
      wrapper: ['ul', { className: 'public-DraftStyleDefault-ul' }]
    },
    'unstyled' => { element: 'div' }
  },
  style_map: {
    'ITALIC' => { fontStyle: 'italic' }
  }
}

# New up the exporter
exporter = DraftjsExporter::HTML.new(config)

# Provide raw content state
exporter.call({
  entityMap: {
    '0' => {
      type: 'LINK',
      mutability: 'MUTABLE',
      data: {
        url: 'http://example.com'
      }
    }
  },
  blocks: [
    {
      key: '5s7g9',
      text: 'Header',
      type: 'header-one',
      depth: 0,
      inlineStyleRanges: [],
      entityRanges: []
    },
    {
      key: 'dem5p',
      text: 'some paragraph text',
      type: 'unstyled',
      depth: 0,
      inlineStyleRanges: [
        {
          offset: 0,
          length: 4,
          style: 'ITALIC'
        }
      ],
      entityRanges: [
        {
          offset: 5,
          length: 9,
          key: 0
        }
      ]
    }
  ]
})
# => "<h1>Header</h1><div>\n<span style=\"font-style: italic;\">some</span> <a href=\"http://example.com\" class=\"link\">paragraph</a> text</div>"
```

## Fork changes

Changes in this fork that are not in upstream `draftjs_exporter`:

### `block_callback:` — hook after each block

Pass a callable to be invoked with the rendered element and the source block, after each block is processed.
Useful for post-processing or collecting metadata as the document is built.

```ruby
exporter = DraftjsExporter::HTML.new(
  block_map: block_map,
  style_map: style_map,
  entity_decorators: entity_decorators,
  block_callback: ->(element, block) { puts "rendered #{block[:type]}" }
)
```

### `className` in `style_map` — CSS classes for inline styles

A `style_map` entry may include a `className:` key. Matching text is given that class, and any remaining keys
in the entry are still emitted as an inline `style` attribute. Classes from multiple applied styles are joined
with a space.

```ruby
style_map = {
  'ITALIC' => { fontStyle: 'italic' },
  'HIGHLIGHT' => { className: 'highlight' },
  'BIG_RED' => { className: 'big', color: 'red' }
}
# 'BIG_RED' text renders as: <span style="color: red;" class="big">...</span>
```

Note that a `className`-only entry still emits an empty `style=""` attribute
(`<span style="" class="highlight">`), as the `style` attribute is always set.

## Tests

```bash
$ rspec
```

