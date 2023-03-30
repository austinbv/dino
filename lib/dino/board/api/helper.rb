module Dino
  module Board
    module API
      module Helper
        def pack(type, data, options={})
          # Always pack as little endian.
          template =  case type
                      when :uint64  then 'Q<*'
                      when :uint32  then 'L<*'
                      when :uint16  then 'S<*'
                      when :uint8   then 'C*'
                      else raise ArgumentError, "unsupported pack format '#{type}'"
                      end

          # Can pass a single integer to get packed if we always [] then flatten.
          str = [data].flatten.pack(template)

          # Pad right with null bytes if asked.
          if options[:pad] && options[:pad] > str.length
            (options[:pad] - str.length).times do
              str = str + "\x00"
            end
          end

          if options[:min] && str.length < options[:min]
            raise ArgumentError, "too few bytes given (expected at least #{options[:min]})"
          end

          # Max should probably always be set to avoid overruning aux message RAM.
          if options[:max] && str.length > options[:max]
            raise ArgumentError, "too many bytes given (expected at most #{options[:max]})"
          end

          str
        end
      end
    end
  end
end
