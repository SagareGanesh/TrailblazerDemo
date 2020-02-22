module Demo::Operation
  class SignupDemo2 < Trailblazer::Operation
    NewUser = Class.new(Trailblazer::Activity::Signal)

    step :validate
    pass :extract_omniauth
    step :find_user, Output(NewUser, :new) => Track(:create)
    step :create_user, Output(:success) => End(:new), magnetic_to: :create
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

  pp Trailblazer::Developer.render(Demo::Operation::SignupDemo2);nil

  #<Start/:default>
  {Trailblazer::Activity::Right} => #<Trailblazer::Activity::TaskBuilder::Task user_proc=validate>
  #<Trailblazer::Activity::TaskBuilder::Task user_proc=validate>
  {Trailblazer::Activity::Left} => #<Railway::End::Failure/:failure>
  {Trailblazer::Activity::Right} => #<Trailblazer::Activity::TaskBuilder::Task user_proc=extract_omniauth>
  #<Trailblazer::Activity::TaskBuilder::Task user_proc=extract_omniauth>
  {Trailblazer::Activity::Left} => #<Trailblazer::Activity::TaskBuilder::Task user_proc=find_user>
  {Trailblazer::Activity::Right} => #<Trailblazer::Activity::TaskBuilder::Task user_proc=find_user>
  #<Trailblazer::Activity::TaskBuilder::Task user_proc=find_user>
  {Trailblazer::Activity::Left} => #<Railway::End::Failure/:failure>
  {Trailblazer::Activity::Right} => #<Trailblazer::Activity::TaskBuilder::Task user_proc=log>
  {Demo::Operation::SignupDemo2::NewUser} => #<Trailblazer::Activity::TaskBuilder::Task user_proc=create_user>
  #<Trailblazer::Activity::TaskBuilder::Task user_proc=create_user>
  {Trailblazer::Activity::Left} => #<Railway::End::Failure/:failure>
  {Trailblazer::Activity::Right} => #<End/:new>
  #<Trailblazer::Activity::TaskBuilder::Task user_proc=log>
  {Trailblazer::Activity::Left} => #<Railway::End::Success/:success>
  {Trailblazer::Activity::Right} => #<Railway::End::Success/:success>
  #<Railway::End::Success/:success>
  #<End/:new>
  #<Railway::End::PassFast/:pass_fast>
  #<Railway::End::FailFast/:fail_fast>
  #<Railway::End::Failure/:failure>

##########################

  Trailblazer::Developer.wtf?(Demo::Operation::SignupDemo2, [ctx]);nil

  ## if user present 
  `-- Demo::Operation::SignupDemo2
    |-- Start.default
    |-- validate
    |-- extract_omniauth
    |-- find_user
    |-- create_user
    `-- End.new

  ##else
  `-- Demo::Operation::SignupDemo2
   |-- Start.default
   |-- validate
   |-- extract_omniauth
   |-- find_user
   |-- log
   `-- End.success

=end
##########################