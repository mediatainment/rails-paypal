require 'httparty'
require 'rails-paypal/nvp-parser'
class RailsPaypal
  include HTTParty
  base_uri "https://api-3t.sandbox.paypal.com/nvp"
  # custom parser must be signed before set the format
  parser NvpParsingIncluded
  # the response format
  format :nvp
#  debug_output # turn on httparty debuy
#  default_timeout 100

  def self.call(data)
    ret = post('/', :body => PARAMS.merge(data))
    ret.parsed_response
  end
end
require 'services/express_checkout'
