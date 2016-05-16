#------------------------------------------------------------------------------
# lib/seeker/response_exception.rb
#------------------------------------------------------------------------------
module Seeker
  
  ##
  # == ResponseException
  # Handles exceptions returned from job search sites API calls.
  #
  # ==== Attributes
  # * +exception+ - System exception that was thrown and caught
  # * +site_name+ - Name of the job search site
  #
  class ResponseException < StandardError
    attr_reader :exception_class_name, :site_name, :error_code
    
    @@default_error_code  = 400
    
    @@http_error_codes    = {
      "OpenSSL::SSL::SSLError"  => { code: 495, description: "SSL Certificate Error" }
    }
    
    def initialize(exception, site_name, exception_class_name = nil)
      @exception_class_name = exception_class_name.nil? ? self.class.to_s : exception_class_name.to_s
      @site_name            = site_name
      @error_code           = get_http_error_code
      
      super(exception)
      set_backtrace(exception.backtrace)
    end # end of initialize()
    
    def self.http_error_codes
      return @@http_error_codes
    end
    
    ##
    # An exception occurred, so the API call failed, report false
    #
    def ok?
      false
    end
    
    def code
      return @error_code[:code]
    end
    
    ##
    # Provide formatted error message
    #
    def error_msg
      "Class=[#{@exception_class_name }], Code=[#{@error_code[:code]}], Message=[#{self.message}]"
    end
    
    ##
    # The <b>msg</b> method provides a duck-typed interface for the standard
    # response <b>msg</b> method, so users can gracefully handle an error from 
    # a single job site API call when calling multiple job search sites, instead
    # of returning an error stating the whole search failed.
    #
    def msg
      
      msg  = {
        header: {
          site_name:      @site_name,
          http:           {
                            code:   @error_code[:code],
                            msg:    @error_code[:description]
                          },
          error:          {
                            code:   @error_code[:code],
                            msg:    self.error_msg
                          }
        },
        body: {
          jobs:     []
        }
      }
      return msg
      
    end # end of msg()
    
    ##
    # Try to figure out the HTTP error code from the class name of the
    # exception
    #
    def get_http_error_code
      err = { code: @@default_error_code, description: "#{@site_name} HTTP Error"}
      
      if @@http_error_codes.has_key?( @exception_class_name )
       err = @@http_error_codes[@exception_class_name]
      end
      
      return err
    end

  end # end of class ResponseException < Exception
  
end # end of module Seeker