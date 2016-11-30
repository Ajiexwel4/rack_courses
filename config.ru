require "./lib/initializer"
require "./lib/access_middleware"

class FirstMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)
    p "Second one"
    [status, headers, [response[0] << " world"]]
  end
end

class SecondMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)
    p "Third one"
    # Rack::Response.new(response[0] << " !", status, headers)
    [status, headers, [response[0] << "!"]]
  end
end

class RackApp
  def call(env)
    p "First one"
    ["200", {"Content-Type" => "text/html"}, ["Hello"]]
  end
end

use SecondMiddleware
use FirstMiddleware

run RackApp.new
