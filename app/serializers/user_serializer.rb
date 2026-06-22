class UserSerializer
  include JSONAPI::Serializer

  attributes :name, :email, :role, :created_at
end
