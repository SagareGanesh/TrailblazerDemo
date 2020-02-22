module Demo::Operation
  class SignupDemo1 < Trailblazer::Operation
    step :validate
    pass :extract_omniauth
    step :find_user
    # fail :create_user, Output(:success) => Track(:success)
    fail :create_user, Output(:success) => Id(:log)
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
  signal, (ctx, _) = Demo::Operation::SignupDemo1.invoke([ctx], {})

  puts signal #=> #<Trailblazer::Activity::Railway::End::Success semantic=:success>
  p ctx[:user] #=>  #<User id: 5, email: "apotonick@gmail.com">

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
  signal, (ctx, _) = Demo::Operation::SignupDemo1.invoke([ctx], {})

  puts signal #=> #<Trailblazer::Activity::End semantic=:success>
  p ctx[:user] #=> #<User id: 1, email: "apotonick@gmail.com">

#########################

  pp Trailblazer::Developer.render(Demo::Operation::SignupDemo1);nil

  #<Start/:default>
  {Trailblazer::Activity::Right} => #<Trailblazer::Activity::TaskBuilder::Task user_proc=validate>
  #<Trailblazer::Activity::TaskBuilder::Task user_proc=validate>
  {Trailblazer::Activity::Left} => #<Trailblazer::Activity::TaskBuilder::Task user_proc=create_user>
  {Trailblazer::Activity::Right} => #<Trailblazer::Activity::TaskBuilder::Task user_proc=extract_omniauth>
  #<Trailblazer::Activity::TaskBuilder::Task user_proc=extract_omniauth>
  {Trailblazer::Activity::Left} => #<Trailblazer::Activity::TaskBuilder::Task user_proc=find_user>
  {Trailblazer::Activity::Right} => #<Trailblazer::Activity::TaskBuilder::Task user_proc=find_user>
  #<Trailblazer::Activity::TaskBuilder::Task user_proc=find_user>
  {Trailblazer::Activity::Left} => #<Trailblazer::Activity::TaskBuilder::Task user_proc=create_user>
  {Trailblazer::Activity::Right} => #<Trailblazer::Activity::TaskBuilder::Task user_proc=log>
  #<Trailblazer::Activity::TaskBuilder::Task user_proc=create_user>
  {Trailblazer::Activity::Left} => #<Railway::End::Failure/:failure>
  {Trailblazer::Activity::Right} => #<Trailblazer::Activity::TaskBuilder::Task user_proc=log>
  #<Trailblazer::Activity::TaskBuilder::Task user_proc=log>
  {Trailblazer::Activity::Left} => #<Railway::End::Success/:success>
  {Trailblazer::Activity::Right} => #<Railway::End::Success/:success>
  #<Railway::End::Success/:success>
  #<Railway::End::PassFast/:pass_fast>
  #<Railway::End::FailFast/:fail_fast>
  #<Railway::End::Failure/:failure>\n

##########################

  Trailblazer::Developer.wtf?(Demo::Operation::SignupDemo1, [ctx]);nil

  `-- Demo::Operation::SignupDemo1
    |-- Start.default
    |-- validate
    |-- extract_omniauth
    |-- find_user
    |-- create_user
    |-- log
    `-- End.success

=end
##########################