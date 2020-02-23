class SimpleWrapper
  def self.call((ctx, flow_options), *, &block)
    begin
      a = yield
      binding.pry
    rescue => exception
      return Trailblazer::Activity::Left, [ctx, flow_options]
    end
  end
end
