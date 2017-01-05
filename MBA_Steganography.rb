require_relative "Image"

# Main
if __FILE__ == $0
    raise "Usage : #{$0} <PNG image file> <message file>" unless ((ARGV.size) == 2 && ARGV[0].downcase.end_with?(".png"))
    input_file = Image.new(ARGV[0])
    input_file.cypher(ARGV[1])
    input_file.write(ARGV[0]+".steg")

    puts Image.new(ARGV[0]+".steg.png").decypher
end
