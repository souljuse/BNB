require 'bcrypt'

class User
  include DataMapper::Resource

  attr_reader :password
  attr_accessor :password_confirmation

  has n, :requests
  has n, :spaces

  validates_confirmation_of :password

  has n, :spaces

  property :id, Serial
  property :email, String, format: :email_address, required: true, unique: true
  property :password_digest, Text
  property :phone_number, String

  def password=(password)
    @password = password
    self.password_digest = BCrypt::Password.create(password)
  end

  def self.authenticate(email, password)
    user = first(email: email)
    if user && BCrypt::Password.new(user.password_digest) == password
      user
    else
      nil
    end
  end

  def requests_received
    @requests = []
    @spaces = Space.all(user_id: id)
    @spaces.each do |space|
      @requests += Request.all(space_id: space.id)
    end
    @requests
  end

  def has_a_phone_number? 
    !self.phone_number.empty?
  end
end
