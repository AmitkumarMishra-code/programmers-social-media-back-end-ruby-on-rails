require 'bcrypt'
class User < ApplicationRecord
  include BCrypt
  has_many :followings
  has_many :following_friends, :through => :followings
  has_many :followers, :class_name => "Following", :foreign_key => "friend_id"
  has_many :follower_friends, :through => :followers, :source => :user
  
  attr_accessor :password
  before_save :prepare_password
  
  validates_presence_of :username
  validates_uniqueness_of :username, :email, :allow_blank => true
  validates_format_of :email, :with => /.*@.*\..*/
  validates_presence_of :password, :on => :create
  validates_confirmation_of :password
  validates_length_of :password, :minimum => 6, :allow_blank => true

  
  def matching_password?(pass)
    pass = Password.new(self.password_hash)
  end
  
  private
  
  def prepare_password
    unless password.blank?
      self.password_hash = encrypt_password(password)
    end
  end
  
  def encrypt_password(pass)
    Password.create(pass)
  end

end
