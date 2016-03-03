require_relative 'app'

require 'sass/plugin/rack'
use Sass::Plugin::Rack

run NacedaEmailTemplateGenerator
