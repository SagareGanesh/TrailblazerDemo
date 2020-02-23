module Demo::Operation
  class CreateUser2 < Trailblazer::Operation
    step Model(User, :new)
    step Contract::Build(constant: Demo::Contract::Form)
    step :extract_params!
    step Contract::Validate(skip_extract: true)
    step Contract::Persist()

    def extract_params!(ctx, params:, **)
      ctx[:"contract.default.params"] = params[:type]
    end
  end
end

#########################
=begin

## Example 1

  ctx = {
    params: {
      type: {
        email: "raju@gmail.com"
      }
    }
  }

  result = Demo::Operation::CreateUser2.(ctx)
  result.success? #=> true

=end
#########################