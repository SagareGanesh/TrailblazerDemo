module Demo::Operation
  class CreateUser3 < Trailblazer::Operation
    step Model(User, :new)
    step Contract::Build()
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

  result = Demo::Operation::CreateUser2.(
    params: { type: { email: "gomu@gmail.com" } },
    :"contract.default.class" => Demo::Contract::Form
  )
  result.success? #=> true


=end
#########################