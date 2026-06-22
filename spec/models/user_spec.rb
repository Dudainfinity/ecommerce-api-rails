require 'rails_helper'

RSpec.describe User, type: :model do
  it "is valid with valid attributes" do
    expect(build(:user)).to be_valid
  end

  it "requires a name" do
    expect(build(:user, name: nil)).not_to be_valid
  end

  it "requires a unique email (case-insensitive)" do
    create(:user, email: "dup@example.com")
    expect(build(:user, email: "DUP@example.com")).not_to be_valid
  end

  it "rejects invalid email formats" do
    expect(build(:user, email: "not-an-email")).not_to be_valid
  end

  it "rejects short passwords" do
    expect(build(:user, password: "123")).not_to be_valid
  end

  it "downcases and strips the email" do
    user = create(:user, email: "  MixedCase@Example.com  ")
    expect(user.email).to eq("mixedcase@example.com")
  end

  it "authenticates with the correct password" do
    user = create(:user, password: "password123")
    expect(user.authenticate("password123")).to be_truthy
    expect(user.authenticate("wrong")).to be_falsey
  end

  it "defaults to the customer role" do
    expect(build(:user).role).to eq("customer")
  end
end
