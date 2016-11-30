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

