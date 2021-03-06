require 'phrender'
require 'embork/server'

class Embork::Phrender < Embork::Server

  def build_app
    cascade_apps = @cascade_apps
    phrender = [Phrender::RackMiddleware, {
      :javascript_files => @borkfile.phrender_javascript_paths,
      :javascript => @borkfile.phrender_raw_javascript,
      :index_file => @borkfile.phrender_index_file
    }]
    backend = @borkfile.backend
    Rack::Builder.new do
      use *phrender
      use backend unless backend == :static_index
      run Rack::Cascade.new(cascade_apps)
    end
  end

end
