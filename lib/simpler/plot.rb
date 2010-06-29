
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
end

