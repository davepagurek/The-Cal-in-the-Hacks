require 'set'
require_relative 'related_words.rb'
require_relative 'word_types.rb'

module CalInTheHacks
  class SentenceBuilder
    def initialize(source, related = nil, word_types = nil)
      @word_types = word_types || CalInTheHacks::WordTypes.new
      @source_file = source
      @related_words = related || CalInTheHacks::RelatedWords.new(source)
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
      regexp = /.*[^A-z]#{word}\b.*\n/i
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
      words = sentence.split(" ")
      words.map! do |w|
        w.gsub(/\bi\b/, 'I')
      end
      words.join(" ")
    end

    def get_sentence(word, num_syllables)
      valid_sentences = []
      15.times do
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
          break
        end
        sentence = contextify(sentence)
        valid_sentences << sentence
      end
      if valid_sentences.size == 0
        raise NoSentenceError
      end
      rank(valid_sentences, word, num_syllables)
    end

    class NoSentenceError < StandardError ; end
  end
end
