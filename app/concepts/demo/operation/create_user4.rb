module Demo::Operation
  class CreateUser4 < Trailblazer::Operation

    class Form < Reform::Form
      property :email
      property :current_user, virtual: true

      validate :current_user?
      validates :email,  presence: true

      def current_user?
        return true if current_user.present?
        errors.add(:current_user, 'should be present')
      end
    end
  
    step Model(User, :new)
    step Contract::Build(constant: Form, builder: :default_contract!)
    step Contract::Validate(key: :user)
    step Contract::Persist()

    def default_contract!(ctx, constant:, model:, **)
      constant.new(model, current_user: ctx[:current_user])
    end

  end
end

#########################
=begin

  ## Example 1

  ctx = {
    params: { user: { email: "ramu@gmail.com" } }
  }

  result = Demo::Operation::CreateUser4.(ctx)
  result.success? #=> true

###########################

  ## Example 2

  ctx = {
    params: { user: { email: "ramu@gmail.com" } },
    current_user: nil
  }

  result = Demo::Operation::CreateUser4.(ctx)
  result.success? #=> false

  result[:"result.contract.default"].errors.messages
  #=> {:current_user=>["should be present"]}

=end
#########################