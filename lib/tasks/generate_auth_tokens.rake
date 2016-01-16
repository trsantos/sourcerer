desc 'Generate auth tokens for existing users'
task generate_auth_tokens: :environment do
  User.where(auth_token: nil).find_each do |u|
    u.generate_token(:auth_token)
    u.save
  end
end
