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
    @r.commands.first.matches /rb\d+ <- c\(2,3,0,3,1,0,0,1\)/
    @r.commands.last.matches /mean\(rb\d+\)/ 
  end

  it 'can get a reply' do
    reply = @r.eval!{"typos = c(2,3,0,3,1,0,0,1)\nmean(typos)\nhist(typos)"}
    reply.chomp.is "[1] 1.25"
  end

  it 'raises a useful Simpler::RError on an R error and shows the submitted R code' do
    code_matches = { "mean(unnamed_variable)" => %r{Error in mean.*: object .* not found},
      "plsdf()" => %r{could not find function},
      "plot(c(1,2), c(2))" => %r{'x' and 'y' lengths differ},
    }
    code_matches.each do |code, matches|
      message = lambda { @r.eval!{code} }.should.raise(Simpler::RError).message
      message.should.match(matches)
      message.should.include code
    end
  end
end

describe 'making data frames' do
  before do
    @hash = {
      :one => [1,2,6,7],
      :two => [3,4,2,9],
      :three => [3,1,1,7],
    }
    @col_names = %w(one two three).map(&:to_sym)
    @row_names = ['spicy', 'cool', 'wetness', 'relative humidity']
  end
  it 'makes data frames with row names' do
    expected =  %Q{                  one two three
spicy               1   3     3
cool                2   4     1
wetness             6   2     1
relative humidity   7   9     7
}
    df = Simpler::DataFrame.new(@hash, @row_names, @col_names)
    as_data_frame = Simpler.new.eval!(df) {|df| df }
    as_data_frame.is expected
  end

  it 'makes data frames with no row names' do
    expected = %Q{  one two three
1   1   3     3
2   2   4     1
3   6   2     1
4   7   9     7
}
    df = Simpler::DataFrame.new(@hash, nil, @col_names)
    as_data_frame = Simpler.new.eval!(df) {|df| df }
    as_data_frame.is expected
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
      @r.eval!(@x, @y) do |x,y|
        @r.plot(file) do
          %Q{
            plot(#{x},#{y}, main="#{ext} scatterplot example", col=rgb(0,100,0,50,maxColorValue=255), pch=16)
          }
        end
      end
      File.exist?(file).is true
      IO.read(@file + ".svg").matches(/svg/) if ext == :svg
      File.unlink(file)
    end
    # pdf and png matching giving: "ArgumentError: invalid byte sequence in UTF-8"
  end
end

describe 'showing plots' do
  before do
    module ::Kernel
      alias_method :old_system, :system
      def system(string) ; $SYSTEM_CALL = string end
    end
    @x = [1,2,3,4,5,6]
    @y = [3,5,4,7,8,2]
    @r = Simpler.new
  end

  after do
    module ::Kernel
      alias_method :system, :old_system
    end
  end

  it 'can disply plots' do
    ok $SYSTEM_CALL.nil?

    @r.show!(@x, @y) do |x,y| 
      "plot(#{x}, #{y})"
    end

    # this shows that we've made a system call to visualize the data
    ok !$SYSTEM_CALL.nil?
  end
end

describe 'ancillary functions' do
  it 'can get the device from the filename' do
    Simpler::Plot.filename_to_plottype("bob.the.pdf").is :pdf
    Simpler::Plot.filename_to_plottype("larry.the.svg").is :svg
  end
end
