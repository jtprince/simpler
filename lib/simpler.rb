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

  # returns the variable name of the object
  def self.varname(obj)
    "rb#{obj.object_id}"
  end

  # returns it as a symbol, currently recognizes pdf, png, svg
  def self.filename_to_plottype(name)
    name.match(/\.([^\.]+)$/)[1].downcase.to_sym
  end

  attr_accessor :commands
  attr_accessor :pdf_viewer

  def initialize(commands=[], opts={:pdf_viewer => PDF_VIEWER})
    @pdf_viewer = opts[:pdf_viewer]
    @commands = commands
  end

  def r_format(object)
    case object
    when String
      object.inspect
    when Numeric
      object.to_s
    else
      object.to_s
    end
  end

  # displays the Rplots.pdf file at the end of execution
  def show!(string=nil)
    if File.exist?(RPLOTS_FILE)
      original_mtime = File.mtime(RPLOTS_FILE)
    end
    reply = run!(string)
    system "#{@pdf_viewer} #{RPLOTS_FILE} &"
    reply
  end

  # pushes string onto command array (if given), executes all commands, and
  # clears the command array.
  def run!(string=nil)
    @commands.push(string) if string
    reply = nil
    Open3.popen3("Rscript -") do |stdin, stdout, stderr|
      stdin.puts @commands.map {|v| v + "\n"}.join
      stdin.close_write
      reply = stdout.read 
    end
    @commands.clear
    Simpler::Reply.new(reply)
  end

  # pushes string onto command array (if given), executes all commands, and
  # clears the command array.
  def run!(string=nil)
    @commands.push(string) if string
    reply = nil
    Open3.popen3("Rscript -") do |stdin, stdout, stderr|
      stdin.puts @commands.map {|v| v + "\n"}.join
      stdin.close_write
      reply = stdout.read 
    end
    @commands.clear
    Simpler::Reply.new(reply)
  end

  # returns self for chaining
  def with(*objects, &block)
    var_names = objects.map {|v| Simpler.varname(v) }
    conversion_code = objects.map {|v| v.to_r }
    @commands.push(*conversion_code)
    @commands << block.call(*var_names)
    self
  end
 
  def go(*objects, &block)
    with(*objects, &block).run!
  end

end
