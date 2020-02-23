require "reform"

module Demo::Contract
  class Form < Reform::Form
    property :email

    validates :email,  presence: true
  end
end