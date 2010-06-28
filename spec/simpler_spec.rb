require 'spec_helper'

require 'simpler'

describe "Simpler" do
  before do
    @typos = [2,3,0,3,1,0,0,1]
    @rate = [2,4,0,3,1,3,0,0]
    @r = Simpler.new
  end

  it "can create valid commands" do
    @r.with(@typos) {|t| "mean(#{t})" }
    @r.commands.first.matches /ruby\d+ <- c\(2,3,0,3,1,0,0,1\)/
    @r.commands.last.matches /mean\(ruby\d+\)/ 
  end

  it 'can get a reply' do
    reply = @r.run!("typos = c(2,3,0,3,1,0,0,1)\nmean(typos)\nhist(typos)")
  
    reply.chomp.is "[1] 1.25"
    1.is 1
  end

end

describe 'making plots' do

  before do
    @x = [1,2,3,4,5,6]
    @y = [3,5,4,7,8,2]
    @file = "plot"
    @exts = %w(svg pdf png).map(&:to_sym)
    @r = Simpler.new
  end

  it 'has convenience wrappers for plotting to file' do
    @exts.each do |ext|
      file = @file + "." + ext
      @r.with(@x, @y) do |x,y|
        plot(file) do
          %Q{
            plot(#{x},#{y}, main="#{ext} scatterplot example", col=rgb(0,100,0,50,maxColorValue=255), pch=16)
          }
        end
      end.run!
      File.exist?(file).is true
      IO.read(@file + ".svg").matches(/svg/) if ext == :svg
      File.unlink(file)
    end
    # pdf and png matching giving: "ArgumentError: invalid byte sequence in UTF-8"
  end

  it 'can disply plots' do
    @r.with(@x, @y) do |x,y| 

      "plot(#{x}, #{y})"


    end.show!
  end
end

describe 'ancillary functions' do
  it 'can get the device from the filename' do
    Simpler.filename_to_plottype("bob.the.pdf").is :pdf
    Simpler.filename_to_plottype("larry.the.svg").is :svg
  end
end
