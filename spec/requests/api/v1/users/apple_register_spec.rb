require 'jwt'

describe 'POST api/v1/users/registrations/apple_sign_up', type: :request do
  let(:jwt_sub) { user_identity }
  let(:jwt_iss) { 'https://appleid.apple.com' }
  let(:jwt_aud) { 'com.apple_sign_in' }
  let(:jwt_iat) { Time.zone.now }
  let(:jwt_exp) { jwt_iat + 5.minutes }
  let(:private_key) { OpenSSL::PKey::RSA.generate(2048) }
  let(:jwk) { JWT::JWK.new(private_key) }
  let(:jwt) do
    {
      iss: jwt_iss,
      aud: jwt_aud,
      exp: jwt_exp.to_i,
      iat: jwt_iat.to_i,
      sub: jwt_sub,
      email: 'timmy@test.com',
      email_verified: 'true',
      is_private_email: 'false'
    }
  end
  let(:signed_jwt) { JWT.encode(jwt, jwk.keypair, 'RS256', kid: jwk.kid) }
  let(:exported_private_key) { JWT::JWK::RSA.new(private_key).export.merge({ alg: 'RS256' }) }

  before do
    stub_request(:get, 'https://appleid.apple.com/auth/keys')
      .to_return(
        body: {
          keys: apple_body
        }.to_json,
        status: 200,
        headers: { 'Content-Type': 'application/json' }
      )
    allow_any_instance_of(AppleSignIn::Token).to receive(:authenticate)
    AppleSignIn.config.apple_client_id = jwt_aud
  end

  let(:params) do
    {
      user_identity: uid,
      jwt: signed_jwt
    }
  end

  subject { post apple_sign_in_api_v1_user_path, params: params, as: :json }

  context 'when the parameters are valid' do
    context 'when the parameters of the initilizer are correct' do
      let(:apple_body) { [exported_private_key] }
      let(:user_identity) { '1234.5678.910' }
      let(:uid) { user_identity }

      context 'when the user was not registered' do
        it 'creates a new user' do
          expect { subject }.to change { User.count }.by(1)
        end
      end

      context 'when the user was registered' do
        before { subject }
        
        it 'creates a new user' do
          expect { subject }.not_to change { User.count }
        end
      end
    end

    context 'when the parameters of the initilizer not valid' do
      let(:apple_body) { [exported_private_key] }
      let(:user_identity) { '1234.5678.910' }
      let(:uid) { '1234.5678.911' }

      it 'does not create a new user' do
        expect { subject }.not_to change { User.count }
      end
    end
  end
end
