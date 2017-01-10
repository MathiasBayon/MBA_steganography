require 'chunky_png'

# Pixel class : represent pixels as 3 RGB color components
class Pixel

    attr_accessor :r, :g, :b, :original_r, :original_g, :original_b

    # Initialize self from RGB int values
    def initialize(r, g, b)
        raise TypeError, "<r>, <g> and <b> must be positive integers" unless ((r.is_a? Numeric) && (g.is_a? Numeric) && (b.is_a? Numeric))
        raise ArgumentError, "<r>, <g> and <b> must be positive integers" unless r >=0 && r <= 255 && g >=0 && g <= 255 && b >=0 && b<= 255
        @r = @original_r = r
        @g = @original_g = g 
        @b = @original_b = b
    end

    # Return self as ChunkyPNG::Color
    def get_color
        ChunkyPNG::Color::rgb(@r, @g, @b)
    end

    # Return Array reprenzentation of self
    def to_a
        [r, g, b]
    end

    # Return String reprezentation of self
    def to_s
        self.to_a.to_s
    end

    def eql?(pixel)
        ((@r == pixel.r) && (@g == pixel.g) && (@b == pixel.b)) && ((@original_r == pixel.original_r) && (@original_g == pixel.original_g) && (@original_b == pixel.original_b))
    end

    def ==(pixel)
        self.eql?(pixel)
    end

    # Store 3 bit chunk within self
    def store(three_bits_as_string)
        self.compress_all
        @r += 1 if three_bits_as_string[0] == "1"
        @g += 1 if three_bits_as_string[1] == "1"
        @b += 1 if three_bits_as_string[2] == "1"
        self
    end

    # Reset RGB color values to original ones
    def reset
        @r = @original_r
        @g = @original_g
        @b = @original_b
    end

    protected

    # Compress every RGB component of self
    def compress_all
        @r = self.compress(@r)
        @g = self.compress(@g)
        @b = self.compress(@b)
    end

    # Get compressed value from provided color_value
    # "Compressed" meaning : with least significant bit set to 0
    def compress(color_value)
        color_as_octet_array = color_value.to_s(2).rjust(8, "0").split("")
        color_as_octet_array[7] = "0"
        color_as_octet_array.join.to_i(2)
    end
    
end