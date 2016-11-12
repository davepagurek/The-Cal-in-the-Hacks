module WestSide
  class << self
    def syllables_in(word)
      if word == "a"
        return 1
      end
      consonant_groups = word.split /[^aeyiuo]/
      consonant_groups = consonant_groups.reject { |c| c.empty? }
      puts consonant_groups
      syllables = consonant_groups.length
      if word[-1] == "e" && !(["a", "e", "i", "o", "u"].include? word[-2])
        syllables -= 1
      end
      syllables
    end

    def get_sentence_syllables(sentence)
      words = sentence.split(" ")
      syllables = 0
      words.each do |word|
        syllables += syllables_in word
      end
      syllables
    end

    def get_lines_around(word)
      prev_line, current_line, line_after = ""
      text = File.read("sources/gatsby.txt")
      context = "((?:.*\n){2})"
      regexp = /.* #{word}.*\n/
      text =~ /^#{context}(#{regexp})#{context}/
      before, match, after = $1.delete("\n"), $2.delete("\n"), $3.delete("\n")
    end

    def get_sentence(word, num_syllables)
      before, match, after = get_lines_around word
      # get type of word
      # choose random template for word ending
      # find types of words needed in surrounding text
    end
  end
end

# puts WestSide.get_sentence("time")
