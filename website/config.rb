configure :development do
  activate :livereload
end

set :markdown_engine, :redcarpet
set :markdown, fenced_code_blocks: true, smartypants: true, tables: true, no_intra_emphasis: true

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

configure :build do
  activate :minify_css
  activate :minify_javascript
end
