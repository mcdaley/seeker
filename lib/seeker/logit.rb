#------------------------------------------------------------------------------
# lib/seeker/logit.rb
#------------------------------------------------------------------------------
module Seeker
  ##
  # Configure logging for the Seeker module. By default, all messages will be
  # logged to STDOUT. An application using the gem, can set their own logger
  # to use.
  #
  # #### Log Levels
  #
  # * +unknown+ - An unknown message that should always be logged.
  # * +fatal+   - An unhandleable error that results in a program crash.
  # * +error+   - A handleable error condition.
  # * +warn+    - A warning.
  # * +info+    - Generic (useful) information about system operation.
  # * +debug+   - Low-level information for developers
  #
  # #### Usage
  #
  # To write a simple message using the default logger:
  #
  #   Seeker.logger.debug  "Example debugging message"
  #
  # To set your own logger and then write some messages using the same
  # interface:
  #
  #   Seeker.logger        = my_logger
  #   Seeker.logger.info   "Reset the gem to use my logger"
  #
  class << self
    attr_writer :logger

    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.progname          = self.name
        log.datetime_format   = '%Y-%m-%d %H:%M:%S'
        log.formatter         = proc do |severity, datetime, progname, msg|
                                  "[#{severity}] (#{datetime}): #{msg}\n"
                                end
      end
    end
  end
  
end # end of module Seeker