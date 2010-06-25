require 'spec_helper'

require 'simpler'

describe "Simpler" do
  before do
    @typos = [2,3,0,3,1,0,0,1]
    @r = R.new
  end

  it "can create valid commands" do
    @r.add(@typos) {|t| "mean(#{t})" }
    @r.commands.first.matches /ruby\d+ <- c\(2,3,0,3,1,0,0,1\)/
    @r.commands.last.matches /mean\(ruby\d+\)/ 
  end

  it 'can get a reply' do
    reply = @r.execute("typos = c(2,3,0,3,1,0,0,1)\nmean(typos)\nhist(typos)\n")
    p reply
    1.is 1
  end
end
