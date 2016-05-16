#------------------------------------------------------------------------------
# lib/configuration.rb
#------------------------------------------------------------------------------
module Seeker
  ##
  # Provide ability to configure the gem's 3rd party api keys using 
  # environment variables. Configuration uses a combination of dotenv and 
  # custom configuration to load the environment variables. 
  #
  # For development and testing the gem, use the dotenv file and set the 
  # environment variables in the '.env' file. When connecting to the gem 
  # from the careerqb application, set the configuration in an 
  # initializer file.
  #
  # #### Configurable Parameters
  #
  # * +indeed_api_key+          - The publisher id needed to access the Indeed API
  # * +career_builder_api_key+  - The deveoper key nedded to access the CareerBuilder API
  #
  # #### Setting Environment with dotenv
  #
  # The dotenv will be the default way to load the environment and it
  # depends on loading the environment variables from the '.env' file in the
  # gem's root directory.
  #
  # The .env file is a simple unix shell environment file (i.e., .bashrc) and
  # has the following format:
  #
  #   export INDEED_PUBLISHER_ID="SECRETKEY"
  #   export CAREER_BUILDER_DEVELOPER_KEY="XYZXYZ"
  #
  # The .env file will be loaded the first time a user creates a job search
  # site.
  #
  # #### Setting the environment in careerqb
  #
  # When running with careerqb then we want to keep the environment variables
  # for the gem contained in the environment files used to setup careerqb.
  #
  # First, add the environment variables to the def.qbmgr.${RAILS_ENV}.sh file
  # as was done when creating the .env file.
  #
  # Second, Create the file config/initializers/seeker.rb and it should have 
  # the following format.
  #
  #   Seeker.configure do |config|
  #     config.indeed_api_key         = ENV["INDEED_PUBLISHER_ID"]
  #     config.career_builder_api_key = ENV["CAREER_BUILDER_DEVELOPER_KEY"]
  #   end
  #
  # #### Usage
  #
  # To use any of the configuration variables in the seeker gem, just call them as
  #
  #   Seeker.configuration.indeed_api_key
  #   Seeker.configuration.career_builder_api_key
  #
  # #### Adding more environment variables
  #
  # As the application grows it will be necessary to add new variables to the
  # configuration, which is straight forward
  #
  # 1.) Add the environment variable to .env and def.qbmgr.${RAILS_ENV}.sh
  #     files.
  #
  # 2.) Add the enviroment variable to the config/initializers/seeker.rb file
  #
  # 3.) Add the attr_accessor to the Configure class in the 
  #     lib/configuration.rb file.
  #
  # 4.) Set the default value for the new variable in the Configuration's 
  #     initialize method
  #
  require 'dotenv'
  
  Dotenv.load
  
  class << self
    attr_accessor     :configuration
  end
  
  def self.configure
    self.configuration    ||= Seeker::Configuration.new
    yield(configuration)  if  block_given?
    
    return self.configuration
  end
  
  class Configuration
    attr_accessor     :indeed_api_key, 
                      :career_builder_api_key
    
    def initialize
      @indeed_api_key         = ENV["INDEED_PUBLISHER_ID"]
      @career_builder_api_key = ENV["CAREER_BUILDER_DEVELOPER_KEY"]
    end
  end
  
end # end of module seeker