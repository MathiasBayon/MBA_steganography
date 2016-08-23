# @author Mathias Bayon

require_relative '../Image'
require 'spec_helper'

RSpec.describe Image do
    before(:each) do
        @image = Image.new("./spec/test.png")
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
        let(:res_filename) { "./spec/res.png" }
        it "Should allow message cyphering within it" do
            message = "Test message"
            @image.cypher(message)
            message_as_binary_array_with_leading_zero = message.split("").map{|char| char.ord.to_s(2).rjust(9,"0").scan(/.{1,3}/)}
            for i in (0..message_as_binary_array_with_leading_zero.length) do
                for j in (0..message_as_binary_array_with_leading_zero[i].length)
                    expect(@image.pixels[[i,0]].r.to_s(2).rjust(8,"0")[7]).to eq message_as_binary_array_with_leading_zero[i][j][0]
                    expect(@image.pixels[[i+1,0]].g.to_s(2).rjust(8,"0")[7]).to eq message_as_binary_array_with_leading_zero[i][j][1]
                    expect(@image.pixels[[i+1,0]].b.to_s(2).rjust(8,"0")[7]).to eq message_as_binary_array_with_leading_zero[i][j][2]
                end
            end
        end

        it "Should be able to write itelf in another file" do
            expect(File.exists? res_filename).not_to be true
            @image.write(res_filename.sub(".png", ""))
            expect(File.exists? res_filename).to be true
            File.delete(res_filename)
        end
    end
end
