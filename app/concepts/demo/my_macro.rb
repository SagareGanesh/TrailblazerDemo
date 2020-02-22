module Demo
  module MyMacro
    def self.ValidUser
      task = ->((ctx, flow_options), _) do
        if ctx[:emial] != "ganesh@joshsoftware.com"
          return Trailblazer::Activity::Right, [ctx, flow_options]
        end
        return Trailblazer::Activity::Left, [ctx, flow_options]
      end

      { task: task, id: 'access_denied' }
    end
  end
end