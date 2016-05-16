#----------------------------------------------------------------------------
# lib/seeker/job_site.rb
#----------------------------------------------------------------------------
module Seeker
  
  ##
  # Base class for all of the supported job search sites.
  #
  class JobSite
    
    ##
    # Define the supported job search sites, needs to be kept in sync with 
    # the job_search_sites DB table 
    #
    @sites = {
      dice: { name: "dice", key: :dice, class_name: 'Seeker::Dice' }
    }
    
    ##
    # Valid job_type params for job search forms
    #
    @@valid_job_type_params     = %w(fulltime  parttime contract internship temporary)
    @@valid_sort_params         = %w(relevance date)
    @@valid_boolean_opr_params  = %w(all any exact)
    
    #--------------------------------------------------------------------------
    # Class Methods
    #--------------------------------------------------------------------------
    class << self
      ##
      # Class method that returns list of supported job search sites
      #
      def sites
        return @sites
      end
    
      ##
      # Class method to return a specific job search site properties by 
      # name, returns nil if the site is not found
      #
      # ==== Attributes
      #
      # * +name+ - String name of the job search site
      #
      # ==== Example
      #
      # indeed = Seeker::JobSite.find("indeed")
      #
      def find(name)
        site =  @sites.has_key?(name.to_sym) ? @sites[name.to_sym] : nil
      end
      
      def find_by_name(name)
        find(name)
      end
      
      ##
      # Class method to return a specific job site properties by a
      # symbol value for the name, returns nil if the site is not found
      #
      # ==== Attributes
      #
      # * +name+ - Symbol name of the job search site
      #
      # ==== Example
      #
      # indeed = Seeker::JobSite.find(:indeed)
      #
      def find_by_symbol(name)
        site = @sites.has_key?(name) ? @sites[name] : nil
      end
      
      def valid_job_type_params
        @@valid_job_type_params
      end
      
      def valid_sort_params
        @@valid_sort_params
      end
      
    end # end of class methods
    
    #--------------------------------------------------------------------------
    # Public
    #--------------------------------------------------------------------------
    attr_accessor :request
    
    def initialize(request = nil)
      @request      = request
      Seeker.configure
    end

    def search(description, location)
      raise "Called abstract method: search"
    end
    
    def advanced_search(params, offset, page)
      raise "Called abstract method: advanced_search"
    end
    
    #--------------------------------------------------------------------------
    # Private
    #--------------------------------------------------------------------------
    private

      ##
      # Return a valid boolean operator used for the the description, if the
      # boolean operator is not set then default to "all" (i.e., AND)
      #
      def validate_boolean_opr(params = {})
        default_boolean_opr = "all"
        
        case params[:boolean_opr]
          when nil?
            boolean_opr = default_boolean_opr
          when "all", "any", "exact"
            boolean_opr = params[:boolean_opr]
          else
            boolean_opr = default_boolean_opr
        end
        
        return boolean_opr
      end

      ##
      # Verify the params[:job_type] submitted in the job search request is
      # valid. Returns true if valid, otherwise returns false.
      #
      def valid_job_type_param?(params)
        return false unless params[:job_type]
        return false unless @@valid_job_type_params.include?(params[:job_type])
        return true
      end
      
      ##
      # Verify the params[:sort] submitted in the job search request is
      # valid. Returns true if valid, otherwise returns false.
      #
      def valid_sort_param?(params)
        return false unless params[:sort]
        return false unless @@valid_sort_params.include?(params[:sort])
        return true
      end
      
      ##
      # Utility to validate positive integer parameter. If the interger 
      # cannot be parsed then return the default API value
      #
      def validate_positive_integer(value, default = "")
        begin
          val  = Integer(value)
          val >= 0 ? val : default
        rescue ArgumentError
          default
        end
      end
    
  end # end of class "JobSite"
    
end # end of module Seeker
