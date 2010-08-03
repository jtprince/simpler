
class Simpler
  module Plot

    # returns it as a symbol, currently recognizes pdf, png, svg
    def self.filename_to_plottype(name)
      name.match(/\.([^\.]+)$/)[1].downcase.to_sym
    end

    def plot(file_w_extension, opts={}, &block)
      device = Simpler::Plot.filename_to_plottype(file_w_extension)
      opts_as_ropts = opts.map {|k,v| "#{k}=#{Simpler.r_format(v)}"}
      string = "#{device}(#{file_w_extension.inspect}, #{opts_as_ropts.join(', ')})\n"
      string << block.call << "\n"
      string << "dev.off()\n"
      string
    end

  end
end

