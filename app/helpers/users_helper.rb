module UsersHelper
  def self.unused_referral_code
    referral_code = SecureRandom.hex(5)
    collision = User.find_by_referral_code(referral_code)

    until collision.nil?
      referral_code = SecureRandom.hex(5)
      collision = User.find_by_referral_code(referral_code)
    end
    referral_code
  end

  def self.unused_unique_id
    id = SecureRandom.hex(8)
    collision = User.find_by_unique_id(id)

    until collision.nil?
      id = SecureRandom.hex(8)
      collision = User.find_by_unique_id(id)
    end
    id
  end
end
