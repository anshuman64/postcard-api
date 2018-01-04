require 'aws-sdk'

class AwsTokenVerifier
  AWS_REGION = 'us-east-1'

  def initialize(identity_pool_id)
    @identity_pool_id = identity_pool_id

    @cognito = Aws::CognitoIdentity::Client.new(
      region: AWS_REGION,
      access_key_id: ENV["AWS_ACCESS_KEY_ID"],
      secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"]
    )
  end

  def get_token(user_id, firebase_jwt)
    identity_id_string = AWS_REGION + ':' + user_id.to_s
    puts identity_id_string

    response = @cognito.get_open_id_token_for_developer_identity(
      identity_pool_id: @identity_pool_id,
      logins: {
        'login.insiya' => firebase_jwt
      },
    )

    return response.identity_id, response.token
  end
end
