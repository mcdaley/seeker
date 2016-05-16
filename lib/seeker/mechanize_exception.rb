#------------------------------------------------------------------------------
# lib/seeker/mechanize_exception.rb
#------------------------------------------------------------------------------
module Seeker
  ##
  # Wrapper class for the MechanizeResponseCode exception class
  #
  class MechanizeException < ResponseException
    attr_reader :mechanize_error
    
    def initialize(exception, site_name)
      super(exception, site_name)
      @mechanize_error = exception
    end
    
    def code
      @mechanize_error.response_code
    end
    
    def page
      @mechanize_error.page
    end 
  end
end