# frozen_string_literal: true

# rails generate devise user
#
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :registerable,
         :confirmable,
         :rememberable,
         :recoverable,
         :trackable,
         :validatable
end
