module Demo::Operation
  class SignupDemo3 < Trailblazer::Operation
    NewUser = Class.new(Trailblazer::Activity::Signal)

    class Validate < Trailblazer::Activity::Railway
      # Yes, you  can use lambdas as steps, too!
      step ->(ctx, params:, **) { params.is_a?(Hash) }
      step ->(ctx, params:, **) { params["info"].is_a?(Hash) },
        Output(:failure) => End(:no_info)
      step ->(ctx, params:, **) { params["info"]["email"] }
    end

    step Subprocess(Validate), Output(:no_info) => End(:no_info)
    ## Its exactly same as
    # step Subprocess(Validate),
    #   Output(:success) => Track(:success),
    #   Output(:failure) => Track(:failure)
    pass :extract_omniauth
    step :find_user, Output(NewUser, :new) => Track(:create)
    step :create_user, Output(:success) => End(:new), magnetic_to: :create
    step Demo::MyMacro.ValidUser
    pass :log
  
    # Validate the incoming Github data.
    # Yes, we could and should use Reform or Dry-validation here.
    def validate(ctx, params:, **)
      is_valid =
        params.is_a?(Hash)         &&
        params["info"].is_a?(Hash) &&
        params["info"]["email"]
  
      is_valid # return value matters!
    end
  
    def extract_omniauth(ctx, params:, **)
      ctx[:email] = params["info"]["email"]
    end
  
    def find_user(ctx, email:, **)
      user = User.find_by(email: email)
      ctx[:user] = user

      user ? true : NewUser
    end

    def create_user(ctx, email:, **)
      ctx[:user] = User.create(email: email)
    end
  
    def log(ctx, **)
      # run some logging here
    end
  
  end
end


########{ test }#########
=begin

## Example 1 - User is not present

  User.destroy_all

  data_from_github = {
    "provider"=>"github",
    "info"=>{
      "nickname"=>"apotonick",
      "email"=>"apotonick@gmail.com",
      "name"=>"Nick Sutterer"
    }
  }

  ctx = {params: data_from_github}
  Trailblazer::Developer.wtf?(Demo::Operation::SignupDemo3, [ctx]);nil

  `-- Demo::Operation::SignupDemo3
    |-- Start.default
    |-- Demo::Operation::SignupDemo3::Validate
    |   |-- Start.default
    |   |-- #<Proc:0x00007fc03c0a67a8@/home/ganesh/Projects/Trailblazer/demo/app/concepts/demo/operation/signup_demo3.rb:7 (lambda)>
    |   |-- #<Proc:0x00007fc030005c10@/home/ganesh/Projects/Trailblazer/demo/app/concepts/demo/operation/signup_demo3.rb:8 (lambda)>
    |   |-- #<Proc:0x00007fc0601c4800@/home/ganesh/Projects/Trailblazer/demo/app/concepts/demo/operation/signup_demo3.rb:9 (lambda)>
    |   `-- End.success
    |-- extract_omniauth
    |-- find_user
    |-- create_user
    `-- End.new

=end
##########################