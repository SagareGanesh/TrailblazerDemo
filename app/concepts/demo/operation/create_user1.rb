module Demo::Operation
  class CreateUser1 < Trailblazer::Operation
    step Model(User, :new)
    step Contract::Build(constant: Demo::Contract::Form)
    step Contract::Validate(key: :user)
    step Contract::Persist()
  end
end

#########################
=begin

## Example 1
  ctx = {
    params: {
      user: {
        email: "ganu@joshsoftware.com"
      }
    }
  }

  result = Demo::Operation::CreateUser1.(ctx)

=end
#########################