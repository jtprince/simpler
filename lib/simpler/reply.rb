
class Simpler
  class Reply < String
    ONE_FLOAT_RE = /] ([\w\.-]+)/o

    # removes the [1] from the line
    def rm_leader
      gsub(/^\[\d+\] /,'')
    end

    def array_cast
      self.chomp.split("\n").rm_leader.split(" ")
    end

    # returns a single float.  Assumes the answer takes the form: "[1] <Float>\n" => Float
    def to_sf
      ONE_FLOAT_RE.match(self)[1].to_f
    end

  end
end
