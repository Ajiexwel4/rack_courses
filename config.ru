require "rack"
require "pry"

Rack::Builder.class_eval do

  def to_app
    app = @map ? generate_map(@run, @map) : @run
    fail "missing run or map statement" unless app
    app = @use.reverse.inject(app) { |a,e| e[a] }
    @warmup.call(app) if @warmup
    # binding.pry
    app
  end

end

Rack::Server.class_eval do
  private

  def build_app(app)
    middleware[options[:environment]].reverse_each do |middleware|
      middleware = middleware.call(self) if middleware.respond_to?(:call)
      next unless middleware
      # binding.pry
      klass, *args = middleware
      app = klass.new(app, *args)
    end
    app
  end
end

class FirstMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    p "Second one"
    status, headers, response = @app.call(env)
    [status, headers, [response[0] << " world"]]
  end
end

class SecondMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    p "First one"
    status, headers, response = @app.call(env)
    [status, headers, [response[0] << "!"]]
  end
end

class RackApp
  def call(env)
    p "Third one"
    ["200", {"Content-Type" => "text/html"}, ["Hello"]]  
  end
end

use SecondMiddleware
use FirstMiddleware

run RackApp.new
