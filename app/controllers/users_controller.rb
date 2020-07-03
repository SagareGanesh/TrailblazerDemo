class UsersController < ApplicationController
  def new
    run Demo::Operation::Create::Present do |result|
      return render cell(
        Demo::Cell::New,
        nil,
        form: @form
      )
    end
  end
end