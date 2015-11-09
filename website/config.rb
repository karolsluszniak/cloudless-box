set :markdown_engine, :redcarpet
set :markdown, fenced_code_blocks: true, smartypants: true, tables: true, no_intra_emphasis: true

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

helpers do
  def version
    @version ||= File.read('source/_changelog.md').match(/(v\d+\.[\w\.]*)/).try(:[], 1)
  end
end

configure :build do
  activate :minify_css
  activate :minify_javascript
end
