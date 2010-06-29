
class Simpler
  class Reply < String

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
end
