# @author Mathias Bayon

require_relative '../Image'
require 'spec_helper'
require 'YAML'

# Properties singleton class
class Messages
    # Returns properties.yaml messages
    def self.get()
        @@messages ||= YAML.load_file("./spec/properties.yaml")
    end
end

class ChunkyPNG::Image
    def self.get_random_image(image_width, image_height)
        png = ChunkyPNG::Image.new(image_width, image_height, ChunkyPNG::Color::TRANSPARENT)
        for x in (0...image_height)
            for y in (0...image_height)
                png[x,y] = ChunkyPNG::Color.rgba(Random.new.rand(0..255), Random.new.rand(0..255), Random.new.rand(0..255), 255)
            end
        end
        png
    end
end

RSpec.describe Image do
    before(:all) do
        test_filename = Messages::get["rspec"]["test_source_image_full_path"]
        image_height = Messages::get["rspec"]["test_source_image_height"]
        image_width = Messages::get["rspec"]["test_source_image_width"]

        unless File.exists? test_filename
            png = ChunkyPNG::Image.get_random_image(image_width, image_height)
            png.save(test_filename, :interlace => true)
        end
        @image = Image.new(test_filename)
    end

    describe "Initialization" do
        it "should give dimensions to the object" do
            expect(@image.height).not_to be_nil
            expect(@image.width).not_to be_nil
            expect(@image.height).not_to be_nil
        end

        it "should decompose the input image file to a pixel hash" do
            expect(@image.pixels.class).to eq Hash
            expect(@image.pixels[[0,0]].class).to eq Pixel
        end

        it "should store input filename in object attributes" do
            expect(@image.filename).to eq "./spec/test.png"
        end
    end

     describe "Methods", :type => :aruba do
        it "Should raise an error if the message to cypher cannot be store within the image" do
            short_message = (0..255).map { ('a'..'z').to_a[rand(26)] }.join
            long_message = (0..250000).map { ('a'..'z').to_a[rand(26)] }.join

            # invoke the private method
            expect(@image.instance_eval{ is_big_enough_to_store_message?(long_message) }).to be false
            expect(@image.instance_eval{ is_big_enough_to_store_message?(short_message) }).to be true
        end

        it "Should allow message cyphering within it" do
            message = Messages::get["rspec"]["test_message"]
            @image.cypher(message)
            message_as_binary_array_with_leading_zero = Image::get_message_as_binary_array_with_leading_zeros(message)
            for i in (0..message_as_binary_array_with_leading_zero.length) do
                expect(@image.pixels[[i,0]].r.to_s(2).rjust(8,"0")[7]).to eq message_as_binary_array_with_leading_zero[i][0]
                expect(@image.pixels[[i,0]].g.to_s(2).rjust(8,"0")[7]).to eq message_as_binary_array_with_leading_zero[i][1]
                expect(@image.pixels[[i,0]].b.to_s(2).rjust(8,"0")[7]).to eq message_as_binary_array_with_leading_zero[i][2]
            end
        end

        it "Should be able to write itelf in another file" do
            res_filename = Messages::get["rspec"]["test_result_image_full_path"]
            File.delete(res_filename) if File.exists? res_filename
            @image.write(res_filename.sub(".png", ""))
            expect(File.exists? res_filename).to be true
        end
    end
end
