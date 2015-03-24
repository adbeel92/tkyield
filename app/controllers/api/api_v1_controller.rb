# encoding: utf-8
class Api::ApiV1Controller < ApplicationController
  skip_before_filter :verify_authenticity_token
  respond_to :json
end
