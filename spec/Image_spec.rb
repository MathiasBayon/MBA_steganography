# @author Mathias Bayon

require 'spec_helper'
require 'YAML'

require_relative '../Image'

# Properties singleton class
class Messages

    # Load properties.yaml files from both MBA_steganography and associated RSpec projects
    # if already loaded, return reference to files contents object
    def self.get()
        @@messages ||= YAML.load_file("./properties.yaml").merge(YAML.load_file("./spec/properties.yaml"))
    end

end

# Rspec tests
RSpec.describe Image do

    # Use existing test image. If no existing test image exists, generate a random one
    before(:all) do

        test_filename = Messages::get["rspec"]["test_source_image_full_path"]
        image_height = Messages::get["rspec"]["test_source_image_height"]
        image_width = Messages::get["rspec"]["test_source_image_width"]

        unless File.exists? test_filename
            png = Image.get_random_image(image_width, image_height)
            png.save(test_filename, :interlace => true)
        end

        @image = Image.new(test_filename)

    end

    # Tests related to Image initialization
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

    # Tests related to Image instance methods
    describe "Methods", :type => :aruba do

        it "Should raise an error if the message to cypher cannot be store within the image" do
            short_message = (0..255).map { ('a'..'z').to_a[rand(26)] }.join
            long_message = (0..250000).map { ('a'..'z').to_a[rand(26)] }.join

            # invoke the private method
            expect(@image.instance_eval{ is_big_enough_to_store_message?(long_message) }).to be false
            expect(@image.instance_eval{ is_big_enough_to_store_message?(short_message) }).to be true
        end

        it "Should allow message cyphering and decyphering" do
            message = Messages::get["rspec"]["test_message"]
            @image.cypher(message)
            expect(message.gsub(Messages::get["cypher"]["ending_flag"], " ")).to eq @image.decypher
        end

        it "Should be able to write itelf in another file" do
            res_filename = Messages::get["rspec"]["test_result_image_full_path"]
            File.delete(res_filename) if File.exists? res_filename
            @image.write(res_filename.sub(".png", ""))
            expect(File.exists? res_filename).to be true
        end

    end

    # Tests related to open class extensions. Here : method to add ending flag to string
    describe "Open classes extensions" do

        it "Should be able to add END flag append to any string" do
            s = "test"
            s_with_ending_flag = s.add_ending_flag
            expect(s_with_ending_flag).to eq "test"+Messages::get["cypher"]["ending_flag"]
        end
        
    end

end
