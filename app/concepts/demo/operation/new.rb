module Demo::Operation
  class New < Trailblazer::Operation
    step Model(User, :new)
    step Contract::Build(constant: Demo::Contract::Form)
  end
end