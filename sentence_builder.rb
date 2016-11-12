require 'set'
require_relative 'related_words.rb'

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
      @related_words = WestSide::RelatedWords.new(source)
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
      regexp = /.*#{word}\b.*\n/i
      text =~ /^#{context}(#{regexp})#{context}/
      before, match, after = $1, $2, $3
      before ||= ""
      match ||= ""
      after ||= ""
      after = after.gsub(/\W/, '')
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

    def score(sentence, word, wanted_syllables)
      score = 0
      words = sentence.split(" ")
      words.each do |w|
        if w != ""
          score += @related_words.relatedness(w, word)
        end
      end
      syllables = get_sentence_syllables(sentence)
      multiplier = 1
      if syllables > wanted_syllables
        multiplier = 1 - (syllables.to_f - wanted_syllables)/wanted_syllables
      elsif syllables < wanted_syllables
        multiplier = syllables.to_f / wanted_syllables
      end
      multiplier * score
    end

    def rank(sentences, word, wanted_syllables)
      scores = sentences.map { |s| score(s, word, wanted_syllables) }
      index = scores.index(scores.max)
      sentences[index]
    end

    def contextify(sentence)
      sentence = sentence.capitalize
      sentence.sub!(".", ";")
      sentence.sub!("Mr;", "Mr.")
      sentence.sub!("Ms;", "Ms.")
      sentence.sub!("Mrs;", "Mrs.")
      sentence.sub!(")", "")
      sentence.sub!("(", "")
      sentence
    end

    def get_sentence(word, num_syllables)
      found_all_sentences = false
      valid_sentences = []
      while found_all_sentences == false do
        before, match, after = get_lines_around word
        sentence = /.*#{word}/i.match(match).to_s
        syllables = get_sentence_syllables sentence
        if syllables > num_syllables
          sentence = remove_syllables(sentence, syllables - num_syllables)
        elsif syllables < num_syllables
          if sentence != ""
            sentence = get_syllables(before, num_syllables - syllables) + " " + sentence
          end
        end
        sentence = sentence.gsub('"', '')
        if sentence.gsub(/\s+/, "").empty?
          found_all_sentences = true
          break
        end
        sentence = contextify(sentence)
        valid_sentences << sentence
      end
      if valid_sentences.size == 0
        return "OOPS"
      end
      rank(valid_sentences, word, num_syllables)
    end
  end
end
