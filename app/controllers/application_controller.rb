class ApplicationController < ActionController::Base
  protect_from_forgery

  include AuthenticatedSystem
  helper :all

  def is_android_client?
    request.headers["User-Agent"] == "android"
  end
end
