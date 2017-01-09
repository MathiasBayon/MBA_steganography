# @author Mathias Bayon

require 'spec_helper'
require 'YAML'

require_relative '../Pixel'

# Rspec tests
RSpec.describe Pixel do

    describe "Initialization" do

        it "should fail if RGB components are not positive and <= 255 integers" do
            expect{Pixel.new("a", "b", "c")}.to raise_error(TypeError)
            expect{Pixel.new(-1, -1, -1)}.to raise_error(ArgumentError)
            expect{Pixel.new(256, 256, 256)}.to raise_error(ArgumentError)
        end

        it "Should have valid RGB components" do
            expect(@pixel.r).not_to be_nil
            expect(@pixel.g).not_to be_nil
            expect(@pixel.b).not_to be_nil
        end

        it "Should be not be compressed after initialization" do
            expect(@pixel.r.to_s(2).rjust(8, "0")).to eq "11111111"
            expect(@pixel.g.to_s(2).rjust(8, "0")).to eq "11111110"
            expect(@pixel.b.to_s(2).rjust(8, "0")).to eq "11111101"
        end

        it "Should allow original value reseting" do
            pixel = Pixel.new(255, 254, 253)
            pixel.r = 10
            pixel.g = 10
            pixel.b = 10
            pixel.reset
            expect(pixel).to eql(Pixel.new(255, 254, 253))
        end

    end

    before(:all) do
        @pixel = Pixel.new(255, 254, 253)
    end

    describe "Methods" do

        it "Should be comparable to another pixel, and equal in case of equal RGB components" do
            expect(Pixel.new(255, 254, 253)).to eql @pixel
            expect(Pixel.new(255, 255, 255)).not_to eql @pixel
        end

        it "Should be able to store three bit as string in its RGB components" do
            @pixel.store("000")
            expect(@pixel.r.to_s(2).rjust(8, "0")).to eq "11111110"
            expect(@pixel.g.to_s(2).rjust(8, "0")).to eq "11111110"
            expect(@pixel.b.to_s(2).rjust(8, "0")).to eq "11111100"
            @pixel.reset
            @pixel.store("001")
            expect(@pixel.r.to_s(2).rjust(8, "0")).to eq "11111110"
            expect(@pixel.g.to_s(2).rjust(8, "0")).to eq "11111110"
            expect(@pixel.b.to_s(2).rjust(8, "0")).to eq "11111101"
            @pixel.reset
            @pixel.store("010")
            expect(@pixel.r.to_s(2).rjust(8, "0")).to eq "11111110"
            expect(@pixel.g.to_s(2).rjust(8, "0")).to eq "11111111"
            expect(@pixel.b.to_s(2).rjust(8, "0")).to eq "11111100"
            @pixel.reset
            @pixel.store("011")
            expect(@pixel.r.to_s(2).rjust(8, "0")).to eq "11111110"
            expect(@pixel.g.to_s(2).rjust(8, "0")).to eq "11111111"
            expect(@pixel.b.to_s(2).rjust(8, "0")).to eq "11111101"
            @pixel.reset
            @pixel.store("100")
            expect(@pixel.r.to_s(2).rjust(8, "0")).to eq "11111111"
            expect(@pixel.g.to_s(2).rjust(8, "0")).to eq "11111110"
            expect(@pixel.b.to_s(2).rjust(8, "0")).to eq "11111100"
            @pixel.reset
            @pixel.store("101")
            expect(@pixel.r.to_s(2).rjust(8, "0")).to eq "11111111"
            expect(@pixel.g.to_s(2).rjust(8, "0")).to eq "11111110"
            expect(@pixel.b.to_s(2).rjust(8, "0")).to eq "11111101"
            @pixel.reset
            @pixel.store("110")
            expect(@pixel.r.to_s(2).rjust(8, "0")).to eq "11111111"
            expect(@pixel.g.to_s(2).rjust(8, "0")).to eq "11111111"
            expect(@pixel.b.to_s(2).rjust(8, "0")).to eq "11111100"
            @pixel.reset
            @pixel.store("111")
            expect(@pixel.r.to_s(2).rjust(8, "0")).to eq "11111111"
            expect(@pixel.g.to_s(2).rjust(8, "0")).to eq "11111111"
            expect(@pixel.b.to_s(2).rjust(8, "0")).to eq "11111101"
            @pixel.reset
        end
        
    end

end
