module WestSide
  class Seussifier
    def initialize()
      @word_maker = WordMaker.new()
      @adjectives = File.read("sources/data/adj").split(/\s+/).to_set
      @adverbs = File.read("sources/data/adv").split(/\s+/).to_set
      @articles = File.read("sources/data/article").split(/\s+/).to_set
      @conjs = File.read("sources/data/conj").split(/\s+/).to_set
      @inters = File.read("sources/data/inter").split(/\s+/).to_set
      @nouns = File.read("sources/data/noun").split(/\s+/).to_set
      @preps = File.read("sources/data/prep").split(/\s+/).to_set
      @pros = File.read("sources/data/pro").split(/\s+/).to_set
      @verb_i = File.read("sources/data/verb_i").split(/\s+/).to_set
      @verb_t = File.read("sources/data/verb_t").split(/\s+/).to_set
      @seuss_dict = File.read("sources/data/seuss_dict").split(/\s+/).to_set
    end

    def type_of(word)
      return "adjective" if @adjectives.include? word
      return "adverb" if @adverbs.include? word
      return "articles" if @articles.include? word
      return "conj" if @conjs.include? word
      return "inter" if @inters.include? word
      return "noun" if @nouns.include? word
      return "prep" if @preps.include? word
      return "pro" if @pros.include? word
      return "verb"
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

    def seussify_line(rap)
      index = rand(0..rap.size - 1)
      words = rap[index].split(" ")
      changed = false
      words.map! do |w|
        if type_of(w) == "noun" && changed == false
          w = @seuss_dict.to_a.sample
          changed = true
        end
        w
      end
      rap[index] = words.join(" ")
      rap
    end

    def seussify(rap)
      rap = modify_pair(rap)
      rap = seussify_line(rap)
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
