class AccessMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    if request.path == "/"
      status, headers, response = @app.call(env)
      Rack::Response.new(response, status, headers)
    else
      Rack::Response.new("Access denied", 403)
    end
  end
end
