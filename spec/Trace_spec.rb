# @author Mathias Bayon

require_relative '../Trace'

RSpec.describe Trace do
   describe "Logger" do
        it "should be a valid singleton Logger" do
            expect(Trace::get_logger).not_to eq nil
            expect(Trace::get_logger.class).to eq Logger
        end
    end
end