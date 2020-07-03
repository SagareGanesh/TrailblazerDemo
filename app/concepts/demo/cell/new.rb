module Demo::Cell
  class New < Trailblazer::Cell
    include ActionView::Helpers::FormOptionsHelper
    include SimpleForm::ActionViewExtensions::FormHelper

    def form
      @options[:form]
    end

  end
end