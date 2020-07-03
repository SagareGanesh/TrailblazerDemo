module Demo::Cell
  class Index < Trailblazer::Cell

    def users
      User.all
    end

  end
end