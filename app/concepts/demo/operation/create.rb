module Demo::Operation
  class Create < Trailblazer::Operation
    step Subprocess(Demo::Operation::New)
    step Contract::Validate(key: :user)
    step Contract::Persist()
  end
end