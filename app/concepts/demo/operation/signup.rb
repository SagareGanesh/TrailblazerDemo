module Demo::Operation
  class Signup < Trailblazer::Operation
    step :validate
    pass :extract_omniauth
    step :find_user
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
    end

    def log(ctx, **)
      # run some logging here
    end

  end
end

########{ test }#########
=begin

## Example 1 - User is not present

  User.where(email: "apotonick@gmail.com").destroy_all

  data_from_github = {
    "provider"=>"github",
    "info"=>{
      "nickname"=>"apotonick",
      "email"=>"apotonick@gmail.com",
      "name"=>"Nick Sutterer"
    }
  }

  ctx = {params: data_from_github}
  signal, (ctx, _) = Demo::Operation::Signup.invoke([ctx], {})

  puts signal #=> #<Trailblazer::Activity::End semantic=:failure>
  p ctx[:user] #=> nil

########################

## Example 2 - User is present

  User.create(email: "apotonick@gmail.com")

  data_from_github = {
  "provider"=>"github",
  "info"=>{
    "nickname"=>"apotonick",
    "email"=>"apotonick@gmail.com",
    "name"=>"Nick Sutterer"
  }
  }

  ctx = {params: data_from_github}
  signal, (ctx, _) = Demo::Operation::Signup.invoke([ctx], {})

  puts signal #=> #<Trailblazer::Activity::End semantic=:success>
  p ctx[:user] #=> #<User id: 1, email: "apotonick@gmail.com">

#########################

  pp Trailblazer::Developer.render(Demo::Operation::Signup);nil

  #<Start/:default>
    {Trailblazer::Activity::Right} => #<Trailblazer::Activity::TaskBuilder::Task user_proc=validate>
  #<Trailblazer::Activity::TaskBuilder::Task user_proc=validate>
    {Trailblazer::Activity::Left} => #<End/:failure>
    {Trailblazer::Activity::Right} => #<Trailblazer::Activity::TaskBuilder::Task user_proc=extract_omniauth>
  #<Trailblazer::Activity::TaskBuilder::Task user_proc=extract_omniauth>
    {Trailblazer::Activity::Left} => #<Trailblazer::Activity::TaskBuilder::Task user_proc=find_user>
    {Trailblazer::Activity::Right} => #<Trailblazer::Activity::TaskBuilder::Task user_proc=find_user>
  #<Trailblazer::Activity::TaskBuilder::Task user_proc=find_user>
    {Trailblazer::Activity::Left} => #<End/:failure>
    {Trailblazer::Activity::Right} => #<Trailblazer::Activity::TaskBuilder::Task user_proc=log>
  #<Trailblazer::Activity::TaskBuilder::Task user_proc=log>
    {Trailblazer::Activity::Left} => #<End/:success>
    {Trailblazer::Activity::Right} => #<End/:success>
  #<End/:success>
  #<End/:failure>

##########################

  Trailblazer::Developer.wtf?(Demo::Operation::Signup, [ctx]);nil

  `-- Signup
    |-- Start.default
    |-- validate
    |-- extract_omniauth
    |-- find_user
    `-- End.failure

=end
##########################