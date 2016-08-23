require_relative "Image"

# Main
if __FILE__ == $0
    raise "Usage : #{$0} crypt / decrypt <message file> <image file>" unless ((ARGV.size) == 3 && ["crypt", "decrypt"].include?(ARGV[0]) && ARGV[2].end_with?(".png"))
    input_file = Image.new(ARGV[2])
    input_file.cypher("toto")
    input_file.write("res")
end
