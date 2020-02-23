module Demo::Operation
  class MultiplyByPi < Trailblazer::Operation
    
    step ->(ctx, **){ ctx[:pi_constant] = 3.14159 }
    step Subprocess(Multiplier),
      input: ->(ctx, pi_constant:, **){{x: 2, y: pi_constant}},
      output: ->(ctx, product:, **){{result: product}}
    step ->(ctx, result:, **){ puts result }

  end
end

######################
=begin
  
  Demo::Operation::MultiplyByPi.()

=end
######################