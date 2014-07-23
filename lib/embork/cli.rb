require 'embork'

class EmborkCLI < Thor
  class_option :borkfile, :type => :string, :default => "./Borkfile",
    :desc => "Path to the embork config file."

  desc "create PACKAGE_NAME", %{generate an Embork Ember application called "PACKAGE_NAME"}
  option :use_ember_data, :type => :boolean, :default => false
  option :directory, :type => :string, :default => nil
  def create(package_name)
    puts %{Creating embork app in "%s"} % package_name
    Embork::Generator.new(package_name, options).generate
  end

  desc "server [ENVIRONMENT]", %{run the development or production server}
  option :port, :type => :numeric, :default => 9292
  option :host, :type => :string, :default => 'localhost'
  option :bundle_version, :type => :string, :default => nil
  option :with_latest_bundle, :type => :boolean, :default => false
  option :enable_tests, :type => :boolean, :default => false
  def server(environment = :development)
    borkfile = Embork::Borkfile.new options[:borkfile], environment
    Embork::Server.new(borkfile, options).run
  end

  desc "test [ENVIRONMENT]", %{run the qunit test suite}
  def test(environment = :development)
    borkfile = Embork::Borkfile.new options[:borkfile], environment
    min = 52000
    max = 65000
    port = (Random.rand * (max - min) + min).to_i
    host = 'localhost'

    server_options = {
      :host => host,
      :port => port,
      :enable_tests => true
    }

    server = Embork::Server.new(borkfile, server_options)

    server_thread = Thread.new{ server.run }

    test_url = "http://%s:%s/tests.html" % [ host, port ]
    Qunit::Runner.new(test_url).run(options[:timeout])
    server_thread.kill
  end

  desc "build [ENVIRONMENT]", %{build the project in the 'build' directory}
  option :keep_all_old_versions, :type => :boolean, :default => false,
    :desc => %{By default, older versions of the project are removed, only keeping the last few versions. This flag keeps all old versions.}
  def build(environment = :production)
    borkfile = Embork::Borkfile.new options[:borkfile], environment
    builder = Embork::Builder.new(borkfile)
    builder.build
    builder.clean unless options[:keep_all_old_versions]
  end

  desc "clean", %{Remove all files under the build directory}
  def clean
    borkfile = Embork::Borkfile.new options[:borkfile]
    FileUtils.rm_rf File.expand_path('build', borkfile.project_root)
  end

  desc "clean-cache", %{Blow away the sprockets cache}
  def clean_cache
    borkfile = Embork::Borkfile.new options[:borkfile]
    FileUtils.rm_rf File.expand_path('.cache', borkfile.project_root)
  end

  desc "hint", %{run jshint on the app and tests}
  option :only_app, :type => :boolean, :default => false
  option :only_tests, :type => :boolean, :default => false
  def hint
    borkfile = Embork::Borkfile.new options[:borkfile]
    Dir.chdir borkfile.project_root do
      system('npm run hint-app') unless options[:only_tests]
      system('npm run hint-testss') unless options[:only_app]
    end
  end

end