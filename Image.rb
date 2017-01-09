require "chunky_png"
require "YAML"
require_relative "Pixel"
require_relative "Trace"

# Properties singleton class
class Messages

    # Returns properties.yaml messages
    def self.get()
        @@messages ||= YAML.load_file("./properties.yaml")
    end

end

class String

  def add_ending_flag
    Messages::get
    ending_flag = Messages::get["cypher"]["ending_flag"]
    self.gsub(ending_flag, " ") + ending_flag
  end

end

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

        @width.times do |w|
            @height.times do |h|
                @pixels[[w,h]] = Pixel.new(
                    ChunkyPNG::Color.r(image_contents[w,h]),
                    ChunkyPNG::Color.g(image_contents[w,h]),
                    ChunkyPNG::Color.b(image_contents[w,h])
                )
            end
        end
    end

    def cypher(message)
        Trace::get_logger.info('Image.cypher') { "Cyphering message..." }
        message_w_ending_flag = message.add_ending_flag
        raise ArgumentError, "Input file is not big enough to store message" unless is_big_enough_to_store_message?(message_w_ending_flag)
        x = y = 0
        message_w_ending_flag.split("").map{|char| char.ord.to_s(2).rjust(8,"0").scan(/.{1,3}/)}

        Image::get_message_as_binary_array_with_leading_zeros(message_w_ending_flag).each do |chunk|
            @pixels[[x,y]].reset
            @pixels[[x,y]].store(chunk)
            x += 1
            if (x == @width)
                x=0
                y+=1
            end
        end

        self
    end

    def decypher
        Trace::get_logger.info('Image.cypher') { "Decyphering message..." }
        
        res_b = res_s = ""

        for y in (0...@height)
            for x in (0...@width)
                res_b += @pixels[[x,y]].r.to_s(2).rjust(8, "0")[7].to_s
                res_b += @pixels[[x,y]].g.to_s(2).rjust(8, "0")[7].to_s
                res_b += @pixels[[x,y]].b.to_s(2).rjust(8, "0")[7].to_s
            end
        end

        for i in (0...res_b.length).step(8)
            chunk = res_b[i...i+8].to_i(2).chr
            break if chunk == Messages::get["cypher"]["ending_flag"]
            res_s += chunk
        end
        
        res_s
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

    def self.get_random_image(image_width, image_height)
        png = ChunkyPNG::Image.new(image_width, image_height, ChunkyPNG::Color::TRANSPARENT)
        for x in (0...image_height)
            for y in (0...image_height)
                png[x,y] = ChunkyPNG::Color.rgba(Random.new.rand(0..255), Random.new.rand(0..255), Random.new.rand(0..255), 255)
            end
        end
        
        png
    end

    private

    def self.get_message_as_binary_array_with_leading_zeros(message)
        message.split("").map{|char| char.ord.to_s(2).rjust(8,"0")}.join.scan(/.{1,3}/)
    end

    def is_big_enough_to_store_message?(message)
        msg_a = Image::get_message_as_binary_array_with_leading_zeros(message)
        msg_a.length <= @width*@height
    end

end
