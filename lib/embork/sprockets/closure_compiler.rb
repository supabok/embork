require 'tilt'
require 'closure-compiler'
require 'embork/logger'

class Embork::Sprockets::ClosureCompiler < Tilt::Template
  self.default_mime_type = 'application/javascript'

  def prepare
    @logger = Embork::Logger.new STDOUT, :simple
  end

  def self.compiler
    @compiler ||= Closure::Compiler.new(
      :jar_file => File.expand_path('../support/closure_compiler.jar', __FILE__),
      :compilation_level => 'SIMPLE_OPTIMIZATIONS'
    )
  end

  def evaluate(scope, locals, &block)
    @logger.info 'Compressing %s.js with the closure compiler' % scope.logical_path
    self.compiler.compile data
  end

end