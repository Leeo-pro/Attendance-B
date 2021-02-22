class Base < ApplicationRecord
  
  validates :base_number, presence: true, on: :update

end
