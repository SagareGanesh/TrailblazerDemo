require "reform"

module Demo::Contract
  class Form < Reform::Form
    include Reform::Form::ActiveModel

    property :email

    validates :email, presence: true
    validates_uniqueness_of :email
  end
end