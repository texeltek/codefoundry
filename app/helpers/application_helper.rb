module ApplicationHelper
  def marker_to_html( markup, options = {} )
    # h() returns a SafeBuffer, but we need a real string before going to 
    # marker so that its output doesn't get escaped in the view
    # http://yehudakatz.com/2010/02/01/safebuffers-and-rails-3-0/
    safe_markup = String.new(h(markup))

    Marker.parse(safe_markup).to_html(options).html_safe
  rescue NoMethodError
    # if Marker cannot parse the markup, it will return Nil and a NoMethodError
    # will be raised for to_html.  Catch this and return default formatting
    # with the error message hidden.
    text_to_html( markup ) + "\n<!-- #{Marker.parser.failure_reason} -->"
  end

  def text_to_html( text, options = {} )
    # do the simplest thing for now
    "<pre>#{text}</pre>"
  end

  def title(page_title)
    content_for(:title) { page_title }
  end

  def start_wide_content
    '<div class="clearfix"></div>'.html_safe
  end

  def svg_tag( source, options = {} )
    options.merge!(
        :src => image_path( source ),
        :pluginspage => 'http://www.adobe.com/svg/viewer/install/',
        :type => 'image/svg+xml',
      )
    attrs = options.map { |key, val| "#{key}=\"#{val}\"" }.join(' ')
    "<embed #{attrs} />".html_safe
  end
  
  def ssl_client_dn
    return request.env["SSL_CLIENT_S_DN"] || ""
  end
end
