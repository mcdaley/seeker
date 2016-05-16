#------------------------------------------------------------------------------
# File:     spec/dice_spec.rb
#------------------------------------------------------------------------------
require 'spec_helper'

##
# Rspec tests to verify that we are able to run advanced jobs 
# search on Dice.com, scrape the results, and generate a standard message.
#
describe "Dice" do
  let(:dice)    { Seeker::Dice.new }
  
  before { Seeker.logger = Logger.new("./log/test.log") }
  
  it "Has a site name" do
    expect(Seeker::Dice.site_name).to eq("dice")
  end
  
  describe "Utilities" do
    it "Maps undefined boolean operator to default" do
      expect(dice.send(:validate_boolean_opr, {})).to                     eq("all")
    end
    
    it "Maps blank boolean operator to default" do
      expect(dice.send(:validate_boolean_opr, {boolean_opr: ""})).to      eq("all")
    end
    
    it "Maps invalid boolean operator to default" do
      expect(dice.send(:validate_boolean_opr, {boolean_opr: "bad"})).to   eq("all")
    end
    
    it "Maps valid boolean operator" do
      %w(all any exact).each do |opr|
        expect(dice.send(:validate_boolean_opr, {boolean_opr: opr})).to   eq(opr)
      end
    end
    
    it "Maps invalid job types to default" do
      %w(full bad).each do |job_type|
        expect(dice.send(:map_to_dice_job_type, job_type)).to eq("")
      end
    end
  
    it "Maps valid job types to dice job type" do
      expect(dice.send( :map_to_dice_job_type, "fulltime"   )).to eq("Full Time")
      expect(dice.send( :map_to_dice_job_type, :fulltime    )).to eq("Full Time")
    
      expect(dice.send( :map_to_dice_job_type, "parttime"   )).to eq("Part Time")
      expect(dice.send( :map_to_dice_job_type, :parttime    )).to eq("Part Time")
    
      expect(dice.send( :map_to_dice_job_type, "contract"   )).to eq("Contract")
      expect(dice.send( :map_to_dice_job_type, :contract    )).to eq("Contract")
    
      expect(dice.send( :map_to_dice_job_type, "internship" )).to eq("")
      expect(dice.send( :map_to_dice_job_type, :internship  )).to eq("")
    
      expect(dice.send( :map_to_dice_job_type, "temporary"  )).to eq("")
      expect(dice.send( :map_to_dice_job_type, :temporary   )).to eq("")
    end
  
    it "Maps invalid sort fields to default" do
      %w(full bad).each do |sort_by|
        expect(dice.send(:map_to_dice_sort_by, sort_by)).to eq("")
      end
    end
  
    it "Maps valid sort by fields to dice sort by" do
      expect(dice.send( :map_to_dice_sort_by, "relevance"   )).to eq("relevance")
      expect(dice.send( :map_to_dice_sort_by, :relevance    )).to eq("relevance")
    
      expect(dice.send( :map_to_dice_sort_by, "date"        )).to eq("date")
      expect(dice.send( :map_to_dice_sort_by, :date         )).to eq("date")
    
      expect(dice.send( :map_to_dice_sort_by, "distance"    )).to eq("")
      expect(dice.send( :map_to_dice_sort_by, :distance     )).to eq("")
    end
  end # end of describe "Utilities"
  
  describe "Advanced Search API" do
    let(:description) { "JavaScript"        }
    let(:location)    { "San Francisco, CA" }
    let(:params)      { {description: description, location: location} }
    
    describe "Build search parameters" do
      describe "Description" do
        let(:boolean_params)  { { 
                                  description:  "Ruby Rails JavaScript",
                                  location:     "94105"
                              } }
        
        it "Handles undefined boolean opr" do
          @options = dice.advanced_search_options(boolean_params)
          expect(@options[:for_all]).to     eq("Ruby Rails JavaScript")
          expect(@options[:for_one]).to     eq("")
          expect(@options[:for_exact]).to   eq("")
        end
        
        it "Matches all words" do
          @options = dice.advanced_search_options(boolean_params.merge(boolean_opr: "all"))
          expect(@options[:for_all]).to     eq("Ruby Rails JavaScript")
          expect(@options[:for_one]).to     eq("")
          expect(@options[:for_exact]).to   eq("")
        end
        
        it "Matches any words" do
          @options = dice.advanced_search_options(boolean_params.merge(boolean_opr: "any"))
          expect(@options[:for_all]).to     eq("")
          expect(@options[:for_one]).to     eq("Ruby Rails JavaScript")
          expect(@options[:for_exact]).to   eq("")
        end
        
        it "Handles exact match" do
          @options = dice.advanced_search_options(boolean_params.merge(boolean_opr: "exact"))
          expect(@options[:for_all]).to     eq("")
          expect(@options[:for_one]).to     eq("")
          expect(@options[:for_exact]).to   eq("Ruby Rails JavaScript")
        end
      end # end of describe "Description"
      
      describe "Job Type" do
        it "Sets default job type to blank string" do
          @options = dice.send(:advanced_search_options, params)
          expect(@options[:for_all]).to     eq("JavaScript")
          expect(@options[:for_one]).to     eq("")
          expect(@options[:for_exact]).to   eq("")
          expect(@options[:for_loc]).to     eq("San Francisco, CA")
          expect(@options[:for_jt]).to      eq("")
        end
      
        it "Handles invalid job types" do
          %w(full bad).each do |job_type|
            @options = dice.send(:advanced_search_options, params.merge(job_type: job_type))
    
            expect(@options[:for_all]).to     eq(description)
            expect(@options[:for_one]).to     eq("")
            expect(@options[:for_exact]).to   eq("")           
            expect(@options[:for_loc]).to     eq(location)
            expect(@options[:for_jt]).to      eq("")
          end
        end
  
        it "Handles valid job types" do
          Seeker::JobSite.valid_job_type_params.each do |job_type|
        
            @options = dice.send(:advanced_search_options, params.merge(job_type: job_type))
    
            expect(@options[:for_all]).to   eq(description)
            expect(@options[:for_loc]).to   eq(location)
            expect(@options[:jtype]).to     eq(dice.send(:map_to_dice_job_type, job_type))
          end
        end
      end # end of describe "Job Type"
    
      describe "Fromage" do
        it "Sets default fromage to blank string" do
          @options = dice.send(:advanced_search_options, params)
        
          expect(@options[:postedDate]).to   eq("")
        end
      
        it "Handles valid fromage values" do
          [3, 7, 14, 17.314, "21", "28"].each do |fromage|
            @options = dice.send(:advanced_search_options, params.merge(fromage: fromage))
        
            expect(@options[:postedDate]).to eq(Integer(fromage))
          end
        end
      
        it "Handles invalid fromage values" do
          ["bad", -3].each do |fromage|
            @options = dice.send(:advanced_search_options, params.merge(fromage: fromage))
        
            expect(@options[:postedDate]).to eq("")
          end
        end
      end # end of describe "Fromage"
    
      describe "Radius" do
        it "Sets defaults radius to blank string" do
          @options = dice.send(:advanced_search_options, params)

          expect(@options[:radius]).to    eq("")
        end
      
        it "Handles valid radius values" do
          [3, 7, 14, 17.314, "21", "28"].each do |radius|
            @options = dice.send(:advanced_search_options, params.merge(radius: radius))
        
            expect(@options[:radius]).to eq(Integer(radius))
          end
        end
      
        it "Handles invalid radius values" do
          ["bad", -3].each do |radius|
            @options = dice.send(:advanced_search_options, params.merge(radius: radius))
        
            expect(@options[:radius]).to eq("")
          end
        end
      end # end of describe "Radius"
    
      describe "Sort" do
        it "Sets default sort type to blank string" do
          @options = dice.send(:advanced_search_options, params)

          expect(@options[:sort]).to  eq("")
        end
      
        it "Handles invalid sort types" do
          %w(full bad).each do |sort|
            @options = dice.send(:advanced_search_options, params.merge(sort: sort))
    
            expect(@options[:sort]).to  eq("")
          end
        end
      
        it "Handles valid sort types" do          
          Seeker::JobSite.valid_sort_params.each do |sort|
            @options = dice.send(:advanced_search_options, params.merge(sort: sort))
    
            expect(@options[:sort]).to  eq(dice.send(:map_to_dice_sort_by, sort))
          end
        end
      end # end of describe "Sort"    
    end # end of describe "Validate parameters"
    
    describe "Valid search", :vcr do
      describe "With description and location" do
        let(:params)    { { description: "JavaScript", location: "San Francisco, CA" } }
        let(:response)  { dice.advanced_search(params) }
        let(:message)   { response.msg }
        
        it "Builds message header" do
          expect(response.ok?).to                       eq(true)
          expect(message[:header][:http][:code]).to     eq(200)
          expect(message[:header][:http][:msg]).to      eq("OK")
          expect(message[:header][:error][:code]).to    eq(0)
          expect(message[:header][:error][:msg]).to     eq("OK")
          expect(message[:header][:total_results]).to   be > 0
          expect(message[:header][:description]).to     eq("JavaScript")
          expect(message[:header][:location]).to        eq("San Francisco, CA")
          expect(message[:header][:radius]).to          eq("30")
          expect(message[:header][:start]).to           eq("1")
          expect(message[:header][:end]).to             eq("5")
          expect(message[:header][:page]).to            eq("1")
          expect(message[:header][:site_name]).to       eq("dice")
        end
        
        it "Returns list of jobs" do
          @job    = message[:body][:jobs][0]
          @count  = Integer(message[:header][:end]) - (Integer(message[:header][:start]) - 1)
          
          expect(message[:body][:jobs].length).to   be > 0
          expect(message[:body][:jobs].length).to   eq(@count)
          expect(@job[:title]).to                   match /\w+/
          expect(@job[:company]).to                 match /\w+/
          expect(@job[:job_url]).to                 match /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix
          expect(@job[:snippet]).to                 match /\w+/
          expect(@job[:key]).to                     match /\w+/
          expect(@job[:uuid]).to                    match /\w+/
          expect(@job[:search_site_job_id]).to      match /\w+/
        end
      end # end of describe "With description and location"
      
      describe "Match any word" do
        let(:params)    {
                          {
                            description:  "Ruby Rails JavaScript", 
                            location:     "San Francisco, CA",
                            boolean_opr:  "any"        
                          }
                        }
        let(:response)  { dice.advanced_search(params) }
        let(:message)   { response.msg                 }
        
        it "Builds message header" do
          expect(response.ok?).to                       eq(true)
          expect(message[:header][:http][:code]).to     eq(200)
          expect(message[:header][:http][:msg]).to      eq("OK")
          expect(message[:header][:error][:code]).to    eq(0)
          expect(message[:header][:error][:msg]).to     eq("OK")
          expect(message[:header][:total_results]).to   be > 0
          expect(message[:header][:description]).to     eq("(Ruby OR Rails OR JavaScript)")
          expect(message[:header][:location]).to        eq("San Francisco, CA")
          expect(message[:header][:radius]).to          eq("30")
          expect(message[:header][:start]).to           eq("1")
          expect(message[:header][:end]).to             eq("5")
          expect(message[:header][:page]).to            eq("1")
          expect(message[:header][:site_name]).to       eq("dice")
        end
        
        it "Returns list of jobs" do
          @job     = message[:body][:jobs][0]
          @count   = Integer(message[:header][:end]) - (Integer(message[:header][:start]) - 1)
          
          expect(message[:body][:jobs].length).to   be > 0
          expect(message[:body][:jobs].length).to   eq(@count)
          expect(@job[:title]).to                   match /\w+/
          expect(@job[:company]).to                 match /\w+/
          expect(@job[:job_url]).to                 match /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix
          expect(@job[:snippet]).to                 match /\w+/
          expect(@job[:key]).to                     match /\w+/
          expect(@job[:uuid]).to                    match /\w+/
          expect(@job[:search_site_job_id]).to      match /\w+/
        end
        
      end # end of describe "With match any word"
      
      describe "Match exact description" do
        let(:params)    {
                          {
                            description:  "Ruby on Rails", 
                            location:     "San Francisco, CA",
                            boolean_opr:  "exact"
        
                          }
                        }
        let(:response)  { dice.advanced_search(params) }
        let(:message)   { response.msg                 }
        
        it "Builds message header" do
          expect(response.ok?).to                       eq(true)
          expect(message[:header][:http][:code]).to     eq(200)
          expect(message[:header][:http][:msg]).to      eq("OK")
          expect(message[:header][:error][:code]).to    eq(0)
          expect(message[:header][:error][:msg]).to     eq("OK")
          expect(message[:header][:total_results]).to   be > 0
          expect(message[:header][:description]).to     eq("\"Ruby on Rails\"")
          expect(message[:header][:location]).to        eq("San Francisco, CA")
          expect(message[:header][:radius]).to          eq("30")
          expect(message[:header][:start]).to           eq("1")
          expect(message[:header][:end]).to             eq("5")
          expect(message[:header][:page]).to            eq("1")
          expect(message[:header][:site_name]).to       eq("dice")
        end
      end # end of describe "Match exact description"
      
      describe "With job type, radius, fromage, and sort options" do
        let(:params)        { 
                              { 
                                description:  "Ruby Rails", location: "94105", 
                                radius:       40,           job_type: "fulltime", 
                                fromage:      20,           sort:     "date",
                                boolean_opr:  "all"
                              } 
                            }
        let(:response)      { dice.advanced_search(params)  }
        let(:message)       { response.msg                  }
        
        it "Builds message header" do
          expect(response.ok?).to                       eq(true)
          expect(message[:header][:http][:code]).to     eq(200)
          expect(message[:header][:http][:msg]).to      eq("OK")
          expect(message[:header][:error][:code]).to    eq(0)
          expect(message[:header][:error][:msg]).to     eq("OK")
          expect(message[:header][:total_results]).to   be > 0
          expect(message[:header][:description]).to     eq("Ruby AND Rails")
          expect(message[:header][:location]).to        eq("94105")
          expect(message[:header][:radius]).to          eq("40")
          expect(message[:header][:start]).to           eq("1")
          expect(message[:header][:end]).to             eq("5")
          expect(message[:header][:page]).to            eq("1")
          expect(message[:header][:site_name]).to       eq("dice")
        end
        
        it "Returns list of jobs" do
          @job     = message[:body][:jobs][0]
          @count   = Integer(message[:header][:end]) - (Integer(message[:header][:start]) - 1)
          
          expect(message[:body][:jobs].length).to   be > 0
          expect(message[:body][:jobs].length).to   eq(@count)
          expect(@job[:title]).to                   match /\w+/
          expect(@job[:company]).to                 match /\w+/
          expect(@job[:job_url]).to                 match /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix
          expect(@job[:snippet]).to                 match /\w+/
          expect(@job[:key]).to                     match /\w+/
          expect(@job[:uuid]).to                    match /\w+/
          expect(@job[:search_site_job_id]).to      match /\w+/
        end
      end # end of Describe "With job type radius, fromage, and sort options"
      
      describe "With paginated results" do
        let(:params)        { 
                              { 
                                description:  "JavaScript", location: "94105", 
                                radius:       50,           fromage:      30
                              } 
                            }
        
        describe "First page" do
          let(:offset)    { 0   }
          let(:per_page)  { 10  }
          let(:response)  { dice.advanced_search(params, offset, per_page) }
          let(:message)   { response.msg }
          
          it "Builds message header" do
            expect(response.ok?).to                       eq(true)
            expect(message[:header][:http][:code]).to     eq(200)
            expect(message[:header][:http][:msg]).to      eq("OK")
            expect(message[:header][:error][:code]).to    eq(0)
            expect(message[:header][:error][:msg]).to     eq("OK")
            expect(message[:header][:total_results]).to   be > 0
            expect(message[:header][:description]).to     eq("JavaScript")
            expect(message[:header][:location]).to        eq("94105")
            expect(message[:header][:radius]).to          eq("50")
            expect(message[:header][:start]).to           eq("1")
            expect(message[:header][:end]).to             eq("10")
            expect(message[:header][:page]).to            eq("1")
            expect(message[:header][:site_name]).to       eq("dice")
          end
        
          it "Returns list of jobs" do
            @job    = message[:body][:jobs][0]
            @count  = Integer(message[:header][:end]) - (Integer(message[:header][:start]) - 1)
          
            expect(message[:body][:jobs].length).to   be > 0
            expect(message[:body][:jobs].length).to   eq(@count)
            expect(@job[:title]).to                   match /\w+/
            expect(@job[:company]).to                 match /\w+/
            expect(@job[:job_url]).to                 match /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix
            expect(@job[:snippet]).to                 match /\w+/
            expect(@job[:key]).to                     match /\w+/
            expect(@job[:uuid]).to                    match /\w+/
            expect(@job[:search_site_job_id]).to      match /\w+/
          end
          
        end # end of describe "First page"
        
        describe "Second page" do
          let(:offset)    { 11  }
          let(:per_page)  { 10  }
          let(:response)  { dice.advanced_search(params, offset, per_page) }
          let(:message)   { response.msg }
          
          it "Builds message header" do
            expect(response.ok?).to                       eq(true)
            expect(message[:header][:http][:code]).to     eq(200)
            expect(message[:header][:http][:msg]).to      eq("OK")
            expect(message[:header][:error][:code]).to    eq(0)
            expect(message[:header][:error][:msg]).to     eq("OK")
            expect(message[:header][:total_results]).to   be > 0
            expect(message[:header][:description]).to     eq("JavaScript")
            expect(message[:header][:location]).to        eq("94105")
            expect(message[:header][:radius]).to          eq("50")
            expect(message[:header][:start]).to           eq("11")
            expect(message[:header][:end]).to             eq("20")
            expect(message[:header][:page]).to            eq("2")
            expect(message[:header][:site_name]).to       eq("dice")
          end
        
          it "Returns list of jobs" do
            @job    = message[:body][:jobs][0]
            @count  = Integer(message[:header][:end]) - (Integer(message[:header][:start]) - 1)
          
            expect(message[:body][:jobs].length).to   be > 0
            expect(message[:body][:jobs].length).to   eq(@count)
            expect(@job[:title]).to                   match /\w+/
            expect(@job[:company]).to                 match /\w+/
            expect(@job[:job_url]).to                 match /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix
            expect(@job[:snippet]).to                 match /\w+/
            expect(@job[:key]).to                     match /\w+/
            expect(@job[:uuid]).to                    match /\w+/
            expect(@job[:search_site_job_id]).to      match /\w+/
          end
          
        end # end of describe "Second page"
      end # end of describe "With paginated results"
      
      describe "With blank location", :vcr do
        let(:blank_params)  { { description: "JavaScript", location: "" } }
        let(:response)      { dice.advanced_search(blank_params)          }
        let(:message)       { response.msg                                }
        
        it "Builds message header" do
          expect(response.ok?).to                       eq(true)
          expect(message[:header][:http][:code]).to     eq(200)
          expect(message[:header][:http][:msg]).to      eq("OK")
          expect(message[:header][:error][:code]).to    eq(0)
          expect(message[:header][:error][:msg]).to     eq("OK")
          expect(message[:header][:total_results]).to   be > 0
          expect(message[:header][:description]).to     eq("JavaScript")
          expect(message[:header][:location]).to        eq("")
          expect(message[:header][:radius]).to          eq("")
          expect(message[:header][:start]).to           eq("1")
          expect(message[:header][:end]).to             eq("5")
          expect(message[:header][:page]).to            eq("1")
        end
        
        it "Returns list of jobs" do
          @job     = message[:body][:jobs][0]
          @count   = Integer(message[:header][:end]) - (Integer(message[:header][:start]) - 1)
          
          expect(message[:body][:jobs].length).to   be > 0
          expect(message[:body][:jobs].length).to   eq(@count)
          expect(@job[:title]).to                   match /\w+/
          expect(@job[:company]).to                 match /\w+/
          expect(@job[:job_url]).to                 match /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix
          expect(@job[:snippet]).to                 match /\w+/
          expect(@job[:key]).to                     match /\w+/
          expect(@job[:uuid]).to                    match /\w+/
          expect(@job[:search_site_job_id]).to      match /\w+/
        end
      end # end of describe "With blank location"
      
      describe "With zero results", :vcr do
        let(:zero_params)   { { description:  "zzz", location: "-2" } }
        let(:zero_response) { dice.advanced_search(zero_params)       }
        let(:zero_message)  { zero_response.msg                       }
      
        it "Returns empty array of jobs" do
          expect(zero_response.ok?).to                      eq(true)
          expect(zero_message[:header][:http][:code]).to    eq(200)
          expect(zero_message[:header][:error][:code]).to   eq(0)
          expect(zero_message[:header][:total_results]).to  eq(0)
          expect(zero_message[:header][:description]).to    eq("zzz")
          expect(zero_message[:header][:location]).to       eq("-2")
          expect(zero_message[:body][:jobs]).to             match_array []
        end
      end # end of describe "With zero results"
      
    end # end of describe "Valid search"
    
    describe "Invalid search", :vcr do
      let(:params) { { description: "JavaScript", location: "94105" } }
      
      describe "Handles HTTP Errors" do
        let(:options) { dice.advanced_search_options(params) }
        
        it "404 page not found error" do
          @bad_url = 'https://www.dice.com/jobs/badURL.html' + '?' + options.to_query
          
          begin
            dice.get(@bad_url)
          rescue Mechanize::ResponseCodeError => e
            @err      = Seeker::MechanizeException.new(e, Seeker::Dice.site_name)
            @response = Seeker::DiceResponse.new(@err)
            @message  = @response.msg
          rescue Exception => e
            @err = Seeker::ResponseException.new(e, Seeker::Dice.site_name)
          end
          
          expect(@response.http_error?).to              eq(true)
          expect(@response.ok?).to                      eq(false)
          expect(@response.error_msg).to                match /HTTP Error, code=\[404\]*/
          expect(@message[:header][:http][:code]).to    eq(404)
          expect(@message[:header][:http][:msg]).to     match /404 => Net::HTTPNotFound/
          expect(@message[:header][:error][:code]).to   eq(1404)
          expect(@message[:header][:error][:msg]).to    match /404 => Net::HTTPNotFound/
          expect(@message[:body][:jobs]).to             match_array []
        end
        
      end # end of describe "Handles HTTP Errors"

    end # end of describe Invalid search
    
  end # end of describe "Advanced Search API"

  describe "Search API", :vcr do
    
    describe "with description and location" do
      let(:response)  { dice.search("Marketing", "94105") }
      let(:message)   { response.msg                      }
    
      it "Builds message header" do
        expect(response.ok?).to                       eq(true)
        expect(message[:header][:http][:code]).to     eq(200)
        expect(message[:header][:http][:msg]).to      eq("OK")
        expect(message[:header][:error][:code]).to    eq(0)
        expect(message[:header][:error][:msg]).to     eq("OK")
        expect(message[:header][:total_results]).to   be > 0
        expect(message[:header][:description]).to     eq("Marketing")
        expect(message[:header][:location]).to        eq("94105")
        expect(message[:header][:radius]).to          eq("30")
        expect(message[:header][:start]).to           eq("1")
        expect(message[:header][:end]).to             eq("5")
        expect(message[:header][:page]).to            eq("1")
        expect(message[:header][:site_name]).to       eq("dice")
      end
      
      it "Returns list of jobs" do
        @job    = message[:body][:jobs][0]
        @count  = Integer(message[:header][:end]) - (Integer(message[:header][:start]) - 1)
        
        expect(message[:body][:jobs].length).to   be > 0
        expect(message[:body][:jobs].length).to   eq(@count)
        expect(@job[:title]).to                   match /\w+/
        expect(@job[:company]).to                 match /\w+/
        expect(@job[:job_url]).to                 match /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix
        expect(@job[:snippet]).to                 match /\w+/
        expect(@job[:key]).to                     match /\w+/
        expect(@job[:search_site_job_id]).to      match /\w+/
      end
    end # end of describe "with description and location"
    
    describe "with zero jobs" do
      let(:zero_response)  { dice.search("zzz", "-2") }
      let(:zero_message)   { zero_response.msg        }
      
      it "Returns empty array of jobs" do
        expect(zero_response.ok?).to                      eq(true)
        expect(zero_message[:header][:http][:code]).to    eq(200)
        expect(zero_message[:header][:error][:code]).to   eq(0)
        expect(zero_message[:header][:total_results]).to  eq(0)
        expect(zero_message[:header][:description]).to    eq("zzz")
        expect(zero_message[:header][:location]).to       eq("-2")
        expect(zero_message[:body][:jobs]).to             match_array []
      end
    end # end of describe "with zero jobs"
  end # end of describe "Search API"

  
end # end of describe "Dice"