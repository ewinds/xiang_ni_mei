# -----------------------------------------------------------------
# PhoneGap Extension
# -----------------------------------------------------------------
# require 'phonegap'
# activate :phonegap

# -----------------------------------------------------------------
# Middleman Build Config
# -----------------------------------------------------------------
configure :build do
  ignore 'javascripts/_*'
  ignore 'javascripts/vendor/*'
  ignore 'stylesheets/_*'
  ignore 'stylesheets/vendor/*'

  set :build_dir, 'd:/BitNami/rubystack-1.9.3-10/apache2/htdocs/xiang'
  #activate :minify_css
  #activate :minify_javascript
  activate :relative_assets
end
