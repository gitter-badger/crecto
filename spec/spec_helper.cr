require "spec"
require "../src/crecto"

class User
  include Crecto::Schema
  extend Crecto::Changeset(User)

  schema "users" do
    field :name, String
    field :things, Int32
    field :stuff, Int32, virtual: true
    field :nope, Float64
    field :yep, Bool
    field :some_date, Time
    field :pageviews, Int64
    has_many :posts, Post
    has_one :thing, Thing
  end

  validate_required :name
end

class UserDifferentDefaults
  include Crecto::Schema
  extend Crecto::Changeset(UserDifferentDefaults)

  created_at_field "xyz"
  updated_at_field nil

  schema "users_different_defaults" do
    field :user_id, Int32, primary_key: true
    field :name, String
  end

  validate_required :name
end

class UserLargeDefaults
  include Crecto::Schema
  extend Crecto::Changeset(UserLargeDefaults)

  created_at_field nil
  updated_at_field nil

  schema "users_large_defaults" do
    field :id, Int64, primary_key: true
    field :name, String
  end
end

class UserRequired
  include Crecto::Schema
  extend Crecto::Changeset(UserRequired)

  schema "users_required" do
    field :name, String
    field :age, Int32
    field :is_admin, Bool
  end

  validate_required :name
  validate_required [:age, :is_admin]
end

class UserFormat
  include Crecto::Schema
  extend Crecto::Changeset(UserFormat)

  schema "users_required" do
    field :name, String
    field :age, Int32
    field :is_admin, Bool
  end

  validate_format :name, /[*a-zA-Z]/
end

class UserInclusion
  include Crecto::Schema
  extend Crecto::Changeset(UserInclusion)

  schema "users_required" do
    field :name, String
    field :age, Int32
    field :is_admin, Bool
  end

  validate_inclusion :name, ["bill", "ted"]
end

class UserExclusion
  include Crecto::Schema
  extend Crecto::Changeset(UserExclusion)

  schema "users_required" do
    field :name, String
    field :age, Int32
    field :is_admin, Bool
  end

  validate_exclusion :name, ["bill", "ted"]
end

class UserLength
  include Crecto::Schema
  extend Crecto::Changeset(UserLength)

  schema "users_required" do
    field :name, String
    field :age, Int32
    field :is_admin, Bool
  end

  validate_length :name, max: 5
end

class UserGenericValidation
  include Crecto::Schema
  extend Crecto::Changeset(UserGenericValidation)

  schema "user_generic" do
    field :id, Int32, primary_key: true
    field :password, String, virtual: true
    field :encrypted_password, String
  end

  validate "Password must exist", ->(user : UserGenericValidation) do
    return false if user.id.nil? || user.id == ""
    return true unless password = user.password
    !password.empty?
  end
end

class UserMultipleValidations
  include Crecto::Schema
  extend Crecto::Changeset(UserMultipleValidations)

  schema "users" do
    field :first_name, String
    field :last_name, String
    field :rank, Int32
  end

  validates :first_name,
    length: {min: 3, max: 9}

  validates [:first_name, :last_name],
    presence: true,
    format: {pattern: /^[a-zA-Z]+$/},
    exclusion: {in: ["foo", "bar"]}

  validates :rank,
    inclusion: {in: 1..100}
end

class Thing
  include Crecto::Schema

  schema "things" do
    belongs_to :user, User, foreign_key: "owner_id"
  end
end

class Post
  include Crecto::Schema

  schema "posts" do
    belongs_to :user, User
  end
end

class Tester
  include Crecto::Schema

  schema "testers" do
    field :oof, String
  end
end
