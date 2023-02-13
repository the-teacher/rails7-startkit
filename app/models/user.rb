# frozen_string_literal: true

# rails generate devise user
#
class User < ApplicationRecord
  # img_path = Rails.root.join('public/Rails7.StartKit.jpg')
  # u = User.first
  # u.avatar.attach(io: File.open(img_path), filename: 'avatar.jpg')
  #
  # u.avatar.purge
  has_one_attached :avatar

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
