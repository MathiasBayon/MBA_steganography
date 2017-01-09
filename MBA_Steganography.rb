require_relative "Image"

# Main
if __FILE__ == $0

    raise "Usage : #{$0} <PNG image file> [<message file> to cypher / <> to decypher]" unless (((ARGV.size == 1) || (ARGV.size == 2)) && ARGV[0].downcase.end_with?(".png"))

    input_file = Image.new(ARGV[0])

    if (ARGV.size == 2) then # Cyphering
        puts "Cyphering : PROCESSING"
        input_file.cypher(ARGV[1])
        output_file = ARGV[0]+".steg"
        input_file.write(ARGV[0]+".steg")
        puts "Cyphering : DONE in #{output_file}"
    else                     # Decyphering
        puts "Decyphering : PROCESSING"
        puts "Message : #{Image.new(ARGV[0]+".steg.png").decypher}"
        puts "Decyphering : DONE"
    end
    
end
