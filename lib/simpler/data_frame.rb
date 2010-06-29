
class Simpler
  # This is an R-centric container for storing data
  class DataFrame
    # this is necessary for
    attr_accessor :col_names
    attr_accessor :row_names
    attr_accessor :hash
    # takes a hash, where the col_name is the key and the data rows are an
    # array of values.  The default ordering of the hash keys will be used,
    # unless overridden with col_names.  The row_names can be used to specify
    # the names of the rows (remains nil if no values specified)
    def initialize(hash, row_names=nil, col_names=nil)
      @hash = hash
      @row_names = row_names
      @col_names = col_names || @hash.keys
    end

    # creates the code to transform the object into R code.  If usefile is
    # specified, the dataframe is written as a table and the code generated
    # will read in the table as a data frame.
    def to_r(usefile=nil)
      if usefile
        raise NotImplementedError, "not implemented just yet"
      else
        # build the vectors
        lines = @col_names.map do |name| 
          val = @hash[name]
          "#{Simpler.varname(val)} <- c(#{val.join(',')})"
        end
        args = @col_names.map do |name|
          "#{name}=#{Simpler.varname(@hash[name])}"
        end
        if @row_names
          varname = Simpler.varname(@row_names)
          lines << "#{varname} <- c(#{@row_names.map {|v| "\"#{v}\""}.join(',')})"
          args.push("row.names=#{varname}")
        end
        lines << "#{Simpler.varname(self)} <- data.frame(#{args.join(', ')})"
        lines.join("\n") << "\n"
      end
    end

  end
end
