secret = Rabotnegi::Application.config.secret_token
message = Vacancy.first.id

verifier = ActiveSupport::MessageVerifier.new(secret)
encryptor = ActiveSupport::MessageEncryptor.new(secret)

p verifier.generate(message), encryptor.encrypt_and_sign(message), encryptor.encrypt_and_sign(message)
p "BAh7B0kiD3Nlc3Npb25faWQGOgZFRiIlZDFkOGM0N2Y4NzZkMGQ2MDhmYjM3OGY5YWY2N2IzMjNJIhBfY3NyZl90b2tlbgY7AEZJIjE3aHNEVjk2VmRhbVQyOVZJUVZjSHVKWHYwRGliSXFyRDQvRGNxeHVmUWdVPQY7AEY%3D--4448899871ab030f6af4b3489efd5939ba529efe"
