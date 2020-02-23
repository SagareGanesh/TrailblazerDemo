module Demo::Operation
  class WrapExample1 < Trailblazer::Operation
    step Wrap(SimpleWrapper){
      step ->(ctx, **) { ctx[:model] = "ganesh" }
      step ->(ctx, **) { false }
       ## Last step is crucial, i.e return value of wrap is crucial
      fail ->(ctx, **) { ctx[:model] = "Failed in wrap" }, fail_fast: true
    }
    fail ->(ctx, **) { ctx[:model] = "Failed" }
    step ->(ctx, **) { ctx[:model] = "Final" }

  end
end


######################################
=begin

result = Demo::Operation::WrapExample1.()
result.success?
result[:model]

=end
#######################################