module WestSide
  class Seussifier
    def initialize()
      @word_maker = WordMaker.new()
    end

    def get_random_pair(rap)
      pairs = rap.size / 2
      index = rand(0..pairs-1)
      2*index
    end

    def modify_pair(rap)
      index = get_random_pair(rap)
      style = @word_maker.suffix[rand(0..@word_maker.suffix.size - 1)]
      last_word = rap[index].split.last
      replacement = @word_maker.make_word(last_word, style, false)
      rap[index].sub!(last_word, replacement)
      last_word = rap[index+1].split.last
      replacement = @word_maker.make_word(last_word, style, true)
      rap[index+1].sub!(last_word, replacement)
      rap
    end

    def seussify(rap)
      rap = modify_pair(rap)
    end

    class WordMaker
      attr_accessor :suffix
      def initialize
        @suffix = ["itty", "uzz", "-a-ma-", "eeds", "izzle"]
      end

      def drop(word, pattern)
        ending = word.match(pattern)
        if ending == nil
          return word
        else
          suffix = ending.to_s
          return word[0...word.length-suffix.length]
        end
      end

      def make_word(word, style, second_pair)
        pattern = /(ing|ed|s)$/n
        if (second_pair)
          pattern = /(ing|ed)$/n
        end
        word = drop(word, pattern)
        word = drop(word, /[aeyiou]+$/n)
        case style
          when "itty"
            word + "-itty " + word
          when "uzz"
            word + "uzz"
          when "-a-ma-"
            word + "-a-ma-" + word.sub(/[^aeyiuo]+/, "f")
          when "izzle"
            word + "izzle"
          else
            word + "eeds"
          end
      end
    end
  end
end
