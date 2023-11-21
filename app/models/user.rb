class User < ApplicationRecord
    has_many :posts, dependent: :destroy
    has_many :comments,  dependent: :destroy
    has_one :like
    validates :email, presence: true, uniqueness: true
    validates :username, presence: true
    validates :password_digest, presence: true
    has_secure_password
end
