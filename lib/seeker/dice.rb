#------------------------------------------------------------------------------
# lib/seeker/dice.rb
#------------------------------------------------------------------------------
module Seeker  
  ##
  # Single file that contains logic for running job searches on dice.com and 
  # for parsing the messages into the standard dogpatch format.
  #
  class Dice < JobSite
    attr_reader :mechanize, :options, :response
    
    @site_name          = 'dice'
    @@dice_url          = "https://www.dice.com/jobs" 
    @@dice_search_url   = "https://www.dice.com/jobs/advancedSearch.html" 
    @@dice_results_url  = "https://www.dice.com/jobs/advancedResult.html"
    
    def initialize(request = nil)
      @mechanize      = Mechanize.new
      super(request)
    end
    
    #--------------------------------------------------------------------------
    # Class Methods
    #--------------------------------------------------------------------------  
    class << self
      ##
      # Return the site name
      #
      def site_name
        @site_name
      end
    end # end class methods
    
    #--------------------------------------------------------------------------  
    # Public Interface
    #--------------------------------------------------------------------------  
    
    ##
    # Run a simple job search on Dice, where user only selects description
    # and location
    #
    # ==== Attributes
    # * +description+ - Words to search
    # * +location+    - Location, city, state, zip code
    # * +offset+      - First job to display, converted to starting page
    # * +per_page+    - Number of jobs to display
    #
    # ==== Example
    # dice      = Seeker::Dice.new
    # response  = dice.search("Accounting", "Chicago, IL", 0, 10)
    #
    def search(description, location, offset = 0, per_page = 5)
      params    = { description: description, location: location }
      response  = advanced_search(params, offset, per_page)
    end
    
    ##
    # Run an advanced job search on Dice.com by directly calling the 
    # advancedResult.html page instead of filling out the advanced search 
    # form and hitting submit. This allows the API to directly search
    # paginated results.
    #
    # ==== Attributes
    # * +params+ -    Hash string that contains all of the advanced search 
    #                 parameters. The supported parameters are description,
    #                 location, job_type, radius, fromage, and sort.
    #                 The description and location are required
    #
    # * +offset+ -    The first job to return in the search results. The number
    #                 is converted to the starting page.
    #
    # * +per_page+ -  The maximum number of jobs to return
    #
    # ==== Examples
    # params  = { description: "Marketing", location: "San Francisco, CA", radius: 10 }
    # dice    = Seeker::Dice.new
    # results = dice.advanced_search(params)
    #
    # # To get the third page of results (i.e. jobs 11 - 15)
    # results = dice.advanced_search(params, 10, 5)
    #
    def advanced_search(params, offset = 0, per_page = 5)
      Seeker.logger.debug( "[JOB_SEARCH]: Dice, params=#{params.inspect}, " + 
                        "offset=#{offset}, per_page=#{per_page}" )
                        
      dice_response     = nil
      
      begin
        options         = advanced_search_options(params, offset, per_page)
        search_url      = build_search_url(options)
      
        page            = get(search_url)
        dice_response   = Seeker::DiceResponse.new(page)
      rescue Mechanize::ResponseCodeError => e
        Seeker.logger.error( "Making Dice API job search, code=[#{e.response_code}], msg=[#{e.message}]" )
        Seeker.logger.error( "#{e.backtrace.inspect}" )
        
        dice_error      = Seeker::MechanizeException.new(e, Seeker::Dice.site_name)
        dice_response   = Seeker::DiceResponse(dice_error)
      rescue Mechanize::ResponseReadError => e
        Seeker.logger.fatal( "Unable to parse Mechanize page, " + 
                          "response=[#{e.response}], error=[#{e.error}]" )
      rescue Exception => e  
        Seeker.logger.error( "Unknown error from Dice, " +
                          "Exception[#{e.class.to_s}], msg=[#{e.message}] ")
        
        dice_exception  = Seeker::ResponseException.new(e, Seeker::Dice.site_name, e.class)
        dice_response   = DiceResponse(dice_exception)
      end
      
      return dice_response
    end # end of advanced_search
    
    ##
    # Run the job search using mechanize, returns the page
    #
    def get(search_url)
      @mechanize.get(search_url)
    end
    
    ##
    # Convert the CareerQB job search parameters to a hash of parameters
    # that can be used to build the URL to run the Dice.com advanced job
    # search. The URL will directly call the Dice jobs/advancedResults.html
    # page and bypass submitting the advanced job search form on 
    # jobs/advancedSearchResults.html. 
    #
    # ==== Query Params
    # The advanedResults.html page support the following parameters:
    # * +for_one+     - Matches one or more terms in string, ORs words
    # * +for_all+     - Matches all words in string, ANDs words
    # * +for_exact+   - Matches exact string
    # * +for_none+    - Matches none of the words
    # * +for_jt+      - Matches words in the job title
    # * +for_com+     - Company, not supported in CareerQB
    # * +for_loc+     - Location, city, state, zip code
    # * +radius+      - Distance from the location in miles to look for jobs
    # * +postedDate+  - Number of days ago job was posted
    # * +jtype+       - Job type, supports Full Time, Part Time, or Contact.
    #                   Dice supports selecting multiple job types, but CareerQB
    #                   is limited to searching all job types or just one
    # * +sort+        - Sort by relevance or date
    # * +limit+       - Number of jobs to display per page
    #
    # ==== Attributes
    # Parameters from advanced_search are forward to method
    #
    # ==== Examples
    #
    def advanced_search_options(params, offset = 0, per_page = 5)
      boolean_opr         = validate_boolean_opr(params)
      description         = params[:description]    || ""
      
      query               = {}
      query[:for_all]     = boolean_opr == "all"    ? description : ""
      query[:for_one]     = boolean_opr == "any"    ? description : ""
      query[:for_exact]   = boolean_opr == "exact"  ? description : ""
      query[:for_none]    = ""
      query[:for_jt]      = ""
      query[:for_com]     = ""
      query[:for_loc]     = params[:location]       || ""
      query[:radius]      = validate_radius(    params  )
      query[:postedDate]  = validate_fromage(   params  )
      query[:jtype]       = validate_job_type(  params  )
      query[:startPage]   = (offset / per_page) + 1 unless Integer(offset/per_page) == 0 # "+ 1" ?
      query[:limit]       = per_page
      query[:sort]        = validate_sort(      params  )
      
      return query
    end # end of advanced_search_options
    
    ##
    # Build the URL to run the Dice.com advanced job search. Converts the 
    # hash of options to a encoded URL
    #
    def build_search_url(options)
      query_params = options.to_query
      url          = @@dice_results_url + '?' + query_params
    end

    #--------------------------------------------------------------------------
    # private
    #--------------------------------------------------------------------------
    private
             
      ##
      # Build a hash of parameters needed to run the job search by submitting the
      # Dice advanced search form. 
      #
      def advanced_search_options_via_search_form(params, offset, per_page)
        query               = {}
        query[:q]           = params[:description]    || ""
        query[:l]           = params[:location]       || ""
        query[:radius]      = validate_radius(    params  )
        query[:postedDate]  = validate_fromage(   params  )
        query[:jtype]       = validate_job_type(  params  )
        query[:startPage]   = (offset / per_page)
        query[:limit]       = per_page
        query[:sort]        = validate_sort(      params  )
        
        return query
      end # end of advanced_search_options
      
      ##
      # Validate the radius as positive integer value
      #
      def validate_radius(params, default = "")
        return default unless params[:radius]
        return validate_positive_integer(params[:radius])
      end
      
      ##
      # Validate the postedDate
      #
      def validate_fromage(params, default = "")
        return default unless params[:fromage]
        return validate_positive_integer(params[:fromage])
      end
      
      ##
      # Validate if it is a valid job type and map it to the supported Dice
      # job types. If the job type is invalid return the default value,
      # which is the blank string, "".
      #
      def validate_job_type(params, default = "")
        return  default unless valid_job_type_param?(params)
        
        params[:job_type].blank? ? default : map_to_dice_job_type(params[:job_type])
      end
      
      ##
      # Map the JobSite job_type field to the string expected by Dice.com
      # job search. Note, that internships and temporary job types are not supported by
      # Dice so returning "" string.
      #
      def map_to_dice_job_type(job_type)
        dice_job_types = {
          fulltime:     "Full Time",
          contract:     "Contract",
          parttime:     "Part Time", 
          internship:   "",
          temporary:    ""
        }
        # Convert string key to a symbol
        job_type  = job_type.is_a?(String) ? job_type.to_sym : job_type
        
        return      dice_job_types.has_key?(job_type) ? dice_job_types[job_type] : "" 
      end
      
      ##
      # Validate the sort type and map it to the appropriate Dice sort type.
      #
      def validate_sort(params, default = "")
        return      default unless valid_sort_param?(params)
        
        params[:sort].blank? ? default : params[:sort]
      end
      
      ##
      # Map the sort_by field to the appropraite Dice sort_by field. If sort_by
      # is blank or not found then return blank string, ""
      #
      def map_to_dice_sort_by(sort_by)
        dice_sort_by = {
          relevance:  "relevance",
          date:       "date",
          distance:   ""                # Distance not supported by JobSite
        }
        # Convert string to symbol    
        sort_by = sort_by.is_a?(String) ? sort_by.to_sym : sort_by
        
        return    dice_sort_by.has_key?(sort_by) ? dice_sort_by[sort_by] : ""
      end

  end # end of class Dice
  
end # end of module Seeker