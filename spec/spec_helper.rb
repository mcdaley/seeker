#------------------------------------------------------------------------------
# spec/spec_helper.rb
#------------------------------------------------------------------------------
require           'vcr'
require_relative  '../lib/seeker'

#
# Configure VCR
#
VCR.configure do |c|
  c.cassette_library_dir      = 'spec/cassettes'
  c.hook_into                   :webmock
  c.default_cassette_options  = { :record => :new_episodes }
  c.configure_rspec_metadata!
end
