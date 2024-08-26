class DatabaseAddOn < AddOn
  validates :metadata, presence: true
  validates :name, uniqueness: { scope: :cluster_id }
  validate :validate_metadata_keys

  def db
    metadata["db"]
  end

  def username
    metadata["username"]
  end

  def password
    metadata["password"]
  end

  def validate_metadata_keys
    validate_keys(["db", "username", "password"])
  end

  def self.make(params)
    # Generate random db, username, password
    db = SecureRandom.hex(16)
    username = SecureRandom.hex(16)
    password = SecureRandom.hex(16)

    create(params.merge(metadata: {
      db:,
      username:,
      password:,
    }))
  end
end