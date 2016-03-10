require 'sinatra'
require 'roadie'
require 'action_view'
require 'sinatra/content_for'

IMAGE_CLASSES = 'image_link'

class NacedaEmailTemplateGenerator < Sinatra::Base

  get '/' do
    @files = Dir[File.dirname(__FILE__) + '/views/emails/*.erb'].map do |filename|
      filename.match(/.+\/([\w-]+)\.erb/)[1]
    end
    erb :home, layout: :'layouts/main'
  end

  get '/templates/:template' do
    @raw = CGI.escapeHTML emailify(params[:template])
    @preview_url = "/templates/#{params[:template]}/preview?#{URI.encode_www_form(params)}"
    erb :template, layout: :'layouts/main'
  end

  get '/templates/:template/preview' do
    emailify params[:template]
  end

  get '/form-news' do
    erb :'/forms/form-news'
  end

  helpers ActionView::Helpers::AssetTagHelper
  helpers Sinatra::ContentFor
  helpers do

    def emailify template
      document = Roadie::Document.new(
        erb(:"emails/#{template}", layout: :'layouts/email')
          .gsub(/<!--\s*STRIP:.+?-->/, '')
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

    def param_exists? parameter
      params[parameter] && !params[parameter].empty?
    end

    def hr
      %(
        <table class="hr" cellpadding="0" cellspacing="0" border="0">
          <tr>
            <td>&nbsp;</td>
          </tr>
        </table>
      )
    end

    def button url, text
      %(
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td>
              <div>
                <!--[if mso]>
                  <v:roundrect xmlns:v="urn:schemas-microsoft-com:vml" xmlns:w="urn:schemas-microsoft-com:office:word" href="#{url}" style="height:36px;v-text-anchor:middle;width:300px;" arcsize="5%" strokecolor="#ccc" fillcolor="#ccc">
                    <w:anchorlock/>
                    <center style="color:#ffffff;>#{text}</center>
                  </v:roundrect>
                <![endif]-->
                <a href="#{url}" class="button" title="#{url}">#{text}</a>
              </div>
            </td>
          </tr>
        </table>
      )
    end


  end
end
