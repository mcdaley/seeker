#------------------------------------------------------------------------------
# spec/job_site_spec.rb
#------------------------------------------------------------------------------
require 'spec_helper'

describe "JobSite" do
  
  it "Returns list of supported sites" do
    @sites = Seeker::JobSite.sites
    
    expect(@sites.length).to                      eq( 1     )
    expect(@sites.has_key?( :dice           )).to eq( true  )
  end

  describe "Find site by name" do
    it "Finds supported site" do
      @dice = Seeker::JobSite.find_by_name("dice")
    
      expect(@dice[:name]).to        eq("dice")
      expect(@dice[:key]).to         eq(:dice)
      expect(@dice[:class_name]).to  eq("Seeker::Dice")
    end
    
    it "Returns nil for unsupported site" do  
      expect(Seeker::JobSite.find_by_name("bad_name")).to  eq(nil)
      expect(Seeker::JobSite.find_by_name(:bad_name)).to   eq(nil)
    end
  
  end # end of describe "Find site by name"
  
  describe "Find site by symbol" do
  
    it "Finds site by symbol" do
      @dice = Seeker::JobSite.find_by_symbol(:dice)
    
      expect(@dice[:name]).to        eq("dice")
      expect(@dice[:key]).to         eq(:dice)
      expect(@dice[:class_name]).to  eq("Seeker::Dice")
    end
    
    it "Returns nil for unsupported site" do
      expect(Seeker::JobSite.find_by_symbol("bad_name")).to  eq(nil)
      expect(Seeker::JobSite.find_by_symbol(:bad_name)).to   eq(nil)
    end
    
  end # end of describe "Find site by symbol"
    
end # end of describe "JobSite"