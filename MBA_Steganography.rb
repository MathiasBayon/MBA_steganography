require 'chunky_png'

class Pixel
    attr_accessor :r, :g, :b

    def initialize(r, g, b)
        @r = r
        @g = g 
        @b = b
        self.compress_all
    end

    def get_color
        ChunkyPNG::Color::rgb(@r, @g, @b)
    end

    def to_a
        [r, g, b]
    end

    def to_s
        self.to_a.to_s
    end

    def eql?(pixel)
        ((@r == pixel.r) && (@g == pixel.g) && (@b == pixel.r))
    end

    def ==(pixel)
        self.eql?(pixel)
    end

    def store(three_bits_as_string)
        @r += 1 if three_bits_as_string[0] == "1"
        @g += 1 if three_bits_as_string[1] == "1"
        @b += 1  if three_bits_as_string[2] == "1"
    end

    protected

    def compress_all
        @r = self.compress(@r)
        @g = self.compress(@g)
        @b = self.compress(@b)
    end

    def compress(color_value)
        color_as_octet_array = color_value.to_s(2).rjust(8, "0").split("")
        color_as_octet_array[7] = "0"
        color_as_octet_array.join.to_i(2)
    end
end

class Image
    attr_reader :height, :width, :filename, :pixels

    def initialize(filename)
        raise "File #{filename} does not exist" unless File.exists?(filename)
        image_contents = ChunkyPNG::Image.from_file(filename)

        @height         = image_contents.dimension.height
        @width          = image_contents.dimension.width
        @filename       = filename
        @pixels         = {}

        @width.times do |x|
            @height.times do |y|
                @pixels[[x,y]] = Pixel.new(
                    ChunkyPNG::Color.r(image_contents[x,y]),
                    ChunkyPNG::Color.g(image_contents[x,y]),
                    ChunkyPNG::Color.b(image_contents[x,y])
                )
            end
        end
    end

    def cypher(message)
        x = y = 0
        message_as_binary_array_with_leading_zero = message.split("").map{|char| char.ord.to_s(2).rjust(9,"0").scan(/.{1,3}/)}
        message_as_binary_array_with_leading_zero.each do |chunk|
            @pixels[[x,y]].store(chunk)
            if (x == @width-1)
                x=0
                y+=1
            end
        end
    end

    def write(output_filename)
        output_file = ChunkyPNG::Image.new(@width, @height, ChunkyPNG::Color::TRANSPARENT)
        @width.times do |x|
            @height.times do |y|
                output_file[x,y] = @pixels[[x,y]].get_color
            end
        end
        output_file.save("#{output_filename}.png", :interlace => false)
    end

    def to_s
        self.pixels.each { |pixel| pixel.to_s }
    end

    private

    def check_x(x)
        self.check_x_or_y(x, :width)
    end

    def check_y(y)
        self.check_x_or_y(y, :height)
    end

    def check_x_and_y(x, y)
        self.check_x(x)
        self.check_y(y)
    end

    def check_x_or_y(x_or_y, height_or_width)
        raise TypeError, "<x> and <y> must be positive Numeric values" unless x_or_y.is_a? Numeric
        raise ArgumentError, "<x> and <y> must be positive Numeric values within image size" unless x_or_y > 0
        raise ArgumentError, "<x> and <y> must be positive Numeric values within image size" unless x_or_y <= @width && height_or_width == :width
        raise ArgumentError, "<x> and <y> must be positive Numeric values within image size" unless x_or_y <= @height && height_or_width == :height
    end
end

# Main
if __FILE__ == $0
    raise "Usage : #{$0} crypt / decrypt <message file> <image file>" unless ((ARGV.size) == 3 && ["crypt", "decrypt"].include?(ARGV[0]) && ARGV[2].end_with?(".png"))
    input_file = Image.new(ARGV[2])
    input_file.cypher("toto")
    input_file.write("res")
end
