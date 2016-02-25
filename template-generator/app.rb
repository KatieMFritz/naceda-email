require 'sinatra'
require 'roadie'
require 'action_view'
require 'sinatra/content_for'

IMAGE_CLASSES = 'image_link'

class NacedaEmailTemplateGenerator < Sinatra::Base

  get '/' do
    @files = Dir[File.dirname(__FILE__) + '/views/emails/*'].map do |filename|
      filename.match(/.+\/(\w+)\.erb/)[1]
    end
    erb :home, layout: :'layouts/main'
  end

  get '/templates/:template' do
    @raw = CGI.escapeHTML emailify(params[:template])
    @preview_url = "/templates/#{params[:template]}/preview"
    erb :template, layout: :'layouts/main'
  end

  get '/templates/:template/preview' do
    emailify params[:template]
  end

  helpers ActionView::Helpers::AssetTagHelper
  helpers Sinatra::ContentFor
  helpers do

    def emailify template
      document = Roadie::Document.new(
        erb :"emails/#{template}", layout: :'layouts/email'
      )
      document.asset_providers = [
        Roadie::FilesystemProvider.new(File.dirname(__FILE__) + '/public/')
      ]
      document.transform
    end

    def phone number
      %(
        <span class="mobile_link">#{number}</span>
      )
    end

    def image source, options
      if options[:class]
        options[:class] += IMAGE_CLASSES
      else
        options[:class] = IMAGE_CLASSES
      end
      image_tag source, options
    end

  end
end
