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

# Open class extension for String
class String

  # Add ending flag to string
  # Ending flag is read from properties file
  # When adding ending flag, make sure is is not already contained within self string
  # If so, remove it
  def add_ending_flag
    Messages::get
    ending_flag = Messages::get["cypher"]["ending_flag"]
    self.gsub(ending_flag, " ") + ending_flag
  end

end

# Image class : initialize, cypher and decypher messages within PNG image
class Image

    attr_reader :height, :width, :filename, :pixels

    # Initialize Image from filename
    def initialize(filename)
        raise ArgumentError, "File #{filename} does not exist" unless File.exists?(filename)
        
        Trace::get_logger.info('Image.initialize') { "Initializating Image from file #{filename}..." }
        
        # Load image contents
        image_contents = ChunkyPNG::Image.from_file(filename)

        # Set attributes from image content, for easier retrieving
        @height         = image_contents.dimension.height
        @width          = image_contents.dimension.width
        @filename       = filename
        @pixels         = {}

        # Fetch each pixel within file, and initialze pixels matrix
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

    # Cypher provided message within self
    def cypher(message)
        Trace::get_logger.info('Image.cypher') { "Cyphering message..." }
        
        # Add ending flag to provided message
        message_w_ending_flag = message.add_ending_flag

        # Check if pixel matric is large enough to store provided message
        raise ArgumentError, "Input file is not big enough to store message" unless is_big_enough_to_store_message?(message_w_ending_flag)
        
        # Transform message into binary array, segmented in 3 bits subarrays
        x = y = 0
        message_w_ending_flag.split("").map{|char| char.ord.to_s(2).rjust(8,"0").scan(/.{1,3}/)}

        # Fetch 3 bits subarrays, and store their content in the least significant bit of each pixel color component
        Image::get_message_as_binary_array_with_leading_zeros(message_w_ending_flag).each do |chunk|
            # Empty least significant bit of pixel color component
            @pixels[[x,y]].reset

            # Store chunk
            @pixels[[x,y]].store(chunk)
            x += 1

            # Climb a row when reaching last pixel column
            if (x == @width)
                x=0
                y+=1
            end
        end

        self
    end

    # Decypher message enclosed within self
    def decypher
        Trace::get_logger.info('Image.cypher') { "Decyphering message..." }
        
        res_b = res_s = ""

        # Fetch each pixel within image, retrieve least significant bit for its color component
        # Store result sequentially in res_b string
        for y in (0...@height)
            for x in (0...@width)
                res_b += @pixels[[x,y]].r.to_s(2).rjust(8, "0")[7].to_s
                res_b += @pixels[[x,y]].g.to_s(2).rjust(8, "0")[7].to_s
                res_b += @pixels[[x,y]].b.to_s(2).rjust(8, "0")[7].to_s
            end
        end

        # Then, fetch octet by octet, convert to char, and append result in res_s string
        for i in (0...res_b.length).step(8)
            chunk = res_b[i...i+8].to_i(2).chr
            break if chunk == Messages::get["cypher"]["ending_flag"]
            res_s += chunk
        end
        
        # Return decyphered string !
        res_s
    end

    # Write self in output file
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

    # Return string representation of self
    def to_s
        self.pixels.each { |pixel| pixel.to_s }
    end

    # Get random image with the dimensions provided as parameters
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

    # Transform string message into binary array, each character beeing represented on 1 octet
    # Then return 3 bit chunks from it
    def self.get_message_as_binary_array_with_leading_zeros(message)
        message.split("").map{|char| char.ord.to_s(2).rjust(8,"0")}.join.scan(/.{1,3}/)
    end

    # Returns true if self is large enough to store provided message
    def is_big_enough_to_store_message?(message)
        msg_a = Image::get_message_as_binary_array_with_leading_zeros(message)
        msg_a.length <= @width*@height
    end

end
