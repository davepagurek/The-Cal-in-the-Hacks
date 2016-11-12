require 'set'

module WestSide
  class SentenceBuilder
    def initialize(source)
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
      @source_file = source
      @text = File.read(@source_file)
    end

    def text
      @text ||= File.read(@source_file)
    end

    def first_vowel(word)
      [word.index("a") || 20, word.index("e") || 20, word.index("i") || 20, word.index("o") || 20, word.index("u") || 20].min
    end

    def syllables_in(word)
      if word == "a"
        return 1
      end
      consonant_groups = word.split /[^aeyiuo]/
      consonant_groups = consonant_groups.reject { |c| c.empty? }
      syllables = consonant_groups.length
      if word[-1] == "e" && !(["a", "e", "i", "o", "u"].include? word[-2]) && first_vowel(word) != word.length - 1
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
      context = "((?:.*\n){2})"
      regexp = /.*#{word}\b.*\n/
      text =~ /^#{context}(#{regexp})#{context}/
      before, match, after = $1, $2, $3
      before ||= ""
      match ||= ""
      after ||= ""
      @text = /#{after}.*/m.match(@text).to_s
      #@text = /(?<=\b)(?!\b#{word}).*/mx.match(@text).to_s.lstrip
      return before, match, after
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

    def validate(sentence)
      return false if sentence.include? "."
      return true
      # types = []
      # sentence.split(" ").each do |word|
      #   types << type_of(word)
      # end
      # return types.include?("verb") && types.include?("noun")
    end

    def remove_syllables(sentence, num_syllables)
      words = sentence.split(" ")
      count = 0
      to_remove = 0
      for i in 0 ... words.size - 1
        count += syllables_in words[i]
        if (count >= num_syllables)
          to_remove = i + 1
          break
        end
      end
      words.drop(to_remove).join(" ")
    end

    def get_syllables(sentence, num_syllables)
      if !sentence
        return ""
      end
      words = sentence.split(" ")
      count = 0
      to_add = 0
      words = words.reverse
      for i in 0 ... words.size
        count += syllables_in words[i]
        if (count >= num_syllables)
          to_add = i + 1
          break
        end
      end
      words.reverse.drop(words.size - to_add).join(" ")
    end

    def evaluate(sentence)

    end

    def get_sentence(word, num_syllables)
      found_all_sentences = false
      valid_sentences = []
      while found_all_sentences == false do
        before, match, after = get_lines_around word
        sentence = /.*#{word}/.match(match).to_s
        syllables = get_sentence_syllables sentence
        if syllables > num_syllables
          sentence = remove_syllables(sentence, syllables - num_syllables)
        elsif syllables < num_syllables
          if sentence != ""
            sentence = get_syllables(before, num_syllables - syllables) + " " + sentence
          end
        end
        if sentence == ""
          found_all_sentences = true
        end
        if validate(sentence)
          valid_sentences << sentence.gsub('"', '')
        end
      end
      valid_sentences
    end
  end
end
