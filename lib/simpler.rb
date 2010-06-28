require 'open3'
require 'tmpdir'

class Array
  def to_r(varname=nil)
    varname ||= Simpler.varname(self)
    "#{varname} <- c(#{self.join(',')})\n"
  end
end

class Simpler ; end

class Simpler::String < String

  # removes the [1] from the line
  def rm_leader
    gsub(/^\[\d+\] /,'')
  end

  def array_cast
    self.chomp.split("\n").rm_leader.split(" ")
  end

  def to_f
  end

  def to_i
    rm_leader.to_f
  end

end

class Simpler
  module Plot

    def plot(file_w_extension, opts={}, &block)
      device = self.class.filename_to_plottype(file_w_extension)
      opts_as_ropts = opts.map {|k,v| "#{k}=#{r_format(v)}"}
      string = "#{device}(#{file_w_extension.inspect}, #{opts_as_ropts.join(', ')})\n"
      string << block.call << "\n"
      string << "dev.off()\n"
      string
    end

  end
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

  # returns [vars, conversion_code]
  def convert(args)
    args.map
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
    reply = execute!(string)
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
    Simpler::String.new(reply)
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
    Simpler::String.new(reply)
  end



  # returns self for chaining
  def with(*args, &block)
    var_names = args.map {|v| Simpler.varname(v) }
    conversion_code = args.map {|v| v.to_r << "\n" }
    (vars, conversion_code) = convert(args) 
    @commands << conversion_code.join("\n")
    @commands << block.call(*vars)
    self
  end
 
end
