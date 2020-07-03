module Demo::Operation
  class Create < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(User, :new)
      step Contract::Build(constant: Demo::Contract::Form)
    end

    step Subprocess(Present)
    step Contract::Validate()
    step Contract::Persist()
  end
end

#########################
=begin

##Example 1
  ctx = {
    params: {
      email: "ganesh@joshsoftware.com"
    }
  }

  result = Demo::Operation::Create.(ctx)
  result.success? #=> true

#########################

##Example 1
  ctx = { params: {} }

  result = Demo::Operation::CreateUser.(ctx)
  result.success? #=> false
  result[:"contract.default"].errors.messages
  #=> {:email=>["can't be blank"]}

=end
#########################