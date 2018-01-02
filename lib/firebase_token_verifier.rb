require 'jwt'
require 'net/http'

class FirebaseTokenVerifier
  VALID_JWT_PUBLIC_KEYS_RESPONSE_CACHE_KEY = 'firebase_phone_jwt_public_keys_cache_key'
  JWT_ALGORITHM                            = 'RS256'
  HEADER_PREFIX                            = 'Bearer '  # Don't remove this space

  def initialize(firebase_project_id)
    @firebase_project_id = firebase_project_id
  end

  def decode(id_token, public_key)
    decoded_token, error = FirebaseTokenVerifier.decode_jwt_token(id_token, @firebase_project_id, nil)

    unless error.nil?
      return nil, error
    end

    payload = decoded_token[0]
    headers = decoded_token[1]

    # Validate headers

    alg = headers['alg']

    unless alg == JWT_ALGORITHM
      return nil, "Invalid access token 'alg' header (#{alg}). Must be '#{JWT_ALGORITHM}'."
    end

    valid_public_keys, error = FirebaseTokenVerifier.retrieve_and_cache_jwt_valid_public_keys
    kid                      = headers['kid']

    unless error.nil?
      return nil, error
    end

    unless valid_public_keys.keys.include?(kid)
      return nil, "Invalid access token 'kid' header, do not correspond to valid public keys."
    end

    # Validate payload
    # We are going to validate Subject ('sub') data only because others params are validated above via 'resque' statement, but we can't do the same with 'sub' there
    # Must be a non-empty string and must be the uid of the user or device

    sub = payload['sub']

    if sub.nil? || sub.empty?
      return nil, "Invalid access token. 'Subject' (sub) must be a non-empty string."
    end

    # Validate signature
    # For this we need to decode one more time, but now with cert public key

    cert_string = valid_public_keys[kid]
    cert = OpenSSL::X509::Certificate.new(cert_string)

    decoded_token, error = FirebaseTokenVerifier.decode_jwt_token(id_token, @firebase_project_id, cert.public_key)

    if decoded_token.nil?
      return nil, error
    end

    return decoded_token[0], nil
  end

  def self.decode_jwt_token(firebase_jwt_token, firebase_project_id, public_key)
    # Validation rules: https://firebase.google.com/docs/auth/admin/verify-id-tokens#verify_id_tokens_using_a_third-party_jwt_library

    unless firebase_jwt_token && firebase_jwt_token.starts_with?(HEADER_PREFIX)
      return nil, "Authorization header not properly configured."
    end

    parsed_token = firebase_jwt_token.gsub(HEADER_PREFIX, '')

    custom_options = {
      verify_iat: true,
      verify_aud: true,
      aud:        firebase_project_id,
      verify_iss: true,
      iss:        "https://securetoken.google.com/" + firebase_project_id
    }

    unless public_key.nil?
      custom_options[:algorithm] = JWT_ALGORITHM
    end

    begin
      decoded_token = JWT.decode(parsed_token, public_key, !public_key.nil?, custom_options)
    rescue JWT::ExpiredSignature
      return nil, "Invalid access token. 'Expiration time' (exp) must be in the future."
    rescue JWT::InvalidIatError
      return nil, "Invalid access token. 'Issued-at time' (iat) must be in the past."
    rescue JWT::InvalidAudError
      return nil, "Invalid access token. 'Audience' (aud) must be your Firebase project ID, the unique identifier for your Firebase project."
    rescue JWT::InvalidIssuerError
      return nil, "Invalid access token. 'Issuer' (iss) Must be 'https://securetoken.google.com/<projectId>', where <projectId> is your Firebase project ID."
    rescue JWT::VerificationError
      return nil, "Invalid access token. Signature verification failed."
    end

    return decoded_token, nil
  end

  def self.retrieve_and_cache_jwt_valid_public_keys
    # Get valid JWT public keys and save to cache
    # Must correspond to one of the public keys listed at
    # https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com

    valid_public_keys = Rails.cache.read(VALID_JWT_PUBLIC_KEYS_RESPONSE_CACHE_KEY)

    if valid_public_keys.nil?
      uri           = URI("https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com")
      https         = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      req           = Net::HTTP::Get.new(uri.path)
      response      = https.request(req)

      unless response.code == '200'
        return nil, "Something went wrong: can't obtain valid JWT public keys from Google."
      end

      valid_public_keys = JSON.parse(response.body)
      cc                = response['cache-control']   # Format example: Cache-Control: public, max-age=24442, must-revalidate, no-transform
      max_age           = cc[/max-age=(\d+?),/m, 1]   # Get something between 'max-age=' and ','

      Rails.cache.write(VALID_JWT_PUBLIC_KEYS_RESPONSE_CACHE_KEY, valid_public_keys, :expires_in => max_age.to_i)
    end

    return valid_public_keys, nil
  end
end
