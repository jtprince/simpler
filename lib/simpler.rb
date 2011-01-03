require 'open3'
require 'simpler/data_frame'
require 'simpler/plot'
require 'simpler/reply'

class Array
  def to_r(varname=nil)
    varname ||= Simpler.varname(self)
    "#{varname} <- c(#{self.join(',')})\n"
  end
end

class Simpler
  include Plot

  RPLOTS_FILE = "Rplots.pdf"
  PDF_VIEWER = "evince"

  # @param [Object] object a ruby object,  
  # @return [String] the variable name of the object
  def self.varname(obj)
    "rb#{obj.object_id}".gsub(/-/,"_")
  end

  attr_accessor :commands
  attr_accessor :pdf_viewer

  # @param [Array] commands a list of R commands to execute
  # @param [Hash] opts options (currently :pdf_viewer which defaults to
  # PDF_VIEWER)
  def initialize(commands=[], opts={:pdf_viewer => PDF_VIEWER})
    @pdf_viewer = opts[:pdf_viewer]
    @commands = commands
  end

  # @example basic
  #   # find the p value of a t-test
  #   r.eval! do 
  #     %Q{
  #       x <- c(1,2,3)
  #       y <- c(4,5,6)
  #       ttest = t.test(x, y)
  #       ttest$p.value
  #     } 
  #   end     # -> "[1] 0.02131164\n"
  #   
  # @example pass in variables (roughly equivalent)
  #   x = [1,2,3]
  #   y = [4,5,6]
  #   r.eval!(x,y) do |xr,yr| 
  #     %Q{
  #       ttest = t.test(#{xr}, #{yr})
  #       ttest$p.value
  #     } 
  #   end     # -> "[1] 0.02131164\n"
  #
  # (see Simpler#with)
  def eval!(*objects, &block)
    with(*objects, &block).run!
  end

  # (see  Simpler#eval!) same as eval! but also opens "Rplots.pdf" with PDF_VIEWER
  # @example plotting
  #   x = [1,2,3]
  #   y = [4,5,6]
  #   r.show!(x,y) do |xr,yr|
  #     "plot(#{xr}, #{yr})"
  #   end
  #
  # Simpler uses Rscript to run its code and Rscript writes X11 output to the
  # PDF file "Rplots.pdf".  Simpler#show! merely makes a system call to open up
  # the pdf file for viewing.  Obviously, for more interactive sessions one
  # should just use R.
  def show!(*objects, &block)
    with(*objects, &block)
    reply = run!
    open_pdf_viewer(@pdf_viewer, RPLOTS_FILE)
    reply
  end

  # @param [*Objects] objects list of objects
  # @yield [*r_varnames] yields the R name of each variable (see Simpler.varname)
  # @return [Simpler] returns self for chaining
  # @example chaining
  #   reply = r.with(dataframe) do |df|
  #     %Q{ ... something with #{df} ... }
  #   end.with(x,y,z) do |xr,yr,zr|
  #     %Q{ ... something with #{xy} #{yr} #{zr} ... }
  #   end.eval!
  #   # can also .show!
  def with(*objects, &block)
    var_names = objects.map {|v| Simpler.varname(v) }
    conversion_code = objects.map {|v| v.to_r }
    @commands.push(*conversion_code)
    unless block.nil?
      @commands << block.call(*var_names)
    end
    self
  end

  # executes all commands and clears the command array.
  # @return [Simpler::Reply] a String subclass
  def run!
    reply = nil
    error = nil
    cmds_to_run = @commands.map {|v| v + "\n"}.join
    Open3.popen3("Rscript -") do |stdin, stdout, stderr|
      stdin.puts cmds_to_run
      stdin.close_write
      error = stderr.read
      reply = stdout.read 
    end
    @commands.clear
    if error.size > 0
      raise Simpler::RError, error_message(error, cmds_to_run)
    end
    Simpler::Reply.new(reply)
  end

  # formats strings and numbers to fit inside R code (this is for Strings and
  # numbers mainly in inclusion in options)
  #   String ==> "\"String\""
  #   Numeric ==> "Numeric"
  #   Other objects => "#{object.to_s}"
  # @param [Object] object the ruby object
  # @return [String] string suitable for R code
  def self.r_format(object)
    case object
    when String
      object.inspect
    when Numeric
      object.to_s
    else
      object.to_s
    end
  end

  def error_message(error_string, r_code)
    error_message = ""
    error_message << "\n"
    error_message << "*************************** Error inside R *****************************\n"
    error_message << error_string
    error_message << "------------------------- [R code submitted] ---------------------------\n"
    error_message << r_code
    error_message << "------------------------------------------------------------------------\n"
    error_message
  end

  def open_pdf_viewer(viewer, *files)
    system "#{@pdf_viewer} #{files.join(" ")} &"
  end

  class RError < StandardError
  end

end
