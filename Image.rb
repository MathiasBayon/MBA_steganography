require 'chunky_png'
require_relative "Pixel"
require_relative "Trace"

class Image
    attr_reader :height, :width, :filename, :pixels

    def initialize(filename)
        raise ArgumentError, "File #{filename} does not exist" unless File.exists?(filename)
        Trace::get_logger.info('Image.initialize') { "Initializating Image from file #{filename}..." }
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
        Trace::get_logger.info('Image.cypher') { "Cyphering message..." }
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
        Trace::get_logger.info('Image.write') { "Writing output file..." }
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
