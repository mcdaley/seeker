#------------------------------------------------------------------------------
# lib/seeker/utils.rb
#------------------------------------------------------------------------------
module Seeker
  
  class Utils
    
    #--------------------------------------------------------------------------
    # Class Methods
    #--------------------------------------------------------------------------
    class << self
      ##
      # Create a UUID string using the job title and the company name. The UUID will 
      # be used to identify duplicate jobs found on multiple job boards
      #
      # #### Attributes
      # * +title+     - Job title
      # * +company+   - Company name
      # * +location+  - Job location
      #
      def uuid(title, company, location)       
        uuid_str  = title.strip + "_" + company.strip + "_" + location.strip
        uuid      = Base64.urlsafe_encode64(CGI.unescape(uuid_str)).slice(0..254)
      end
    end # end of class << self
    
  end # end of module Utils
  
end # end of module Seeker