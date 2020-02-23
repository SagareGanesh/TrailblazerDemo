module Demo::Operation
  class Multiplier < Trailblazer::Operation

    step ->(ctx, x:, y:, **){ ctx[:product] = x*y }

  end
end