class UsersController < ApplicationController
  def index
    return render cell(Demo::Cell::Index)
  end

  def new
    run Demo::Operation::New do
      return render cell(Demo::Cell::New, @form)
    end
    

    # run Demo::Operation::Create::Present do |result|
    #   return render cell(
    #     Demo::Cell::New,
    #     nil,
    #     form: @form
    #   )
    # end
  end

  def create
    run Demo::Operation::Create do |result|
      return redirect_to users_path
    end

    return render cell(Demo::Cell::New, @form)



    # run Demo::Operation::Create do |result|
    #   return redirect_to users_path
    # end

    # return render cell(
    #   Demo::Cell::New,
    #   nil,
    #   form: @form
    # )
  end
end