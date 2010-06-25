require 'open3'

class Array
  def to_r
    var = "ruby#{self.object_id}"
    convert = "#{var} <- c(#{self.join(',')})\n"
    [var, convert]
  end
end

class Simpler::String < String

  # removes the [1] from the line
  def rm_leader
    gsub(/^\[\d+\] /,'')
  end

  # 
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

  attr_accessor :commands
  def initialize(commands=[])
    @commands = commands
  end

  def add(*args, &block)
    (vars, conversion_code) = args.map(&:to_r).inject([[],[]]) {|ar, double| [0,1].each {|i| ar[i].push(double[i]) } ; ar }
    @commands << conversion_code.join("\n")
    @commands << block.call(*vars)
  end


  def execute(cmds=nil)
    case cmds
    when Array
      @commands.push(*cmds)
    when String
      @commands << cmds
    end
    reply = nil
    Open3.popen3("Rscript -") do |stdin, stdout, stderr|
      stdin.puts @commands.map {|v| v + "\n"}.join
      stdin.close_write
      reply = stdout.read 
    end
    reply
  end

  alias_method '[]'.to_sym, :execute

end
