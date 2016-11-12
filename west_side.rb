#!/usr/bin/env ruby

require_relative 'sentence_builder.rb'
require_relative 'related_words.rb'
require_relative 'rhyming.rb'

module WestSide
  class Builder
    def initialize(
      source: "#{File.dirname(__FILE__)}/sources/gatsby.txt",
      num_couplets: 5
    )
      @related = WestSide::RelatedWords.new(source)
      @sentence = WestSide::SentenceBuilder.new(source)
      @num_couplets = num_couplets
    end

    def words_sample
      @related.words.to_a.shuffle[0..10].to_a.sort
    end

    def build(seed, syllables)
      generate_endings(seed)
        .map{|w| @sentence.get_sentence(w, syllables)}
    end

    def valid_words
      @related.words
    end

    def generate_endings(word)
      endings = [word]
      while endings.length < @num_couplets*2 do
        puts endings.inspect
        if endings.empty?
          puts "First word was bad :("
          return
        end
        begin
          if endings.length.odd?
            endings.push(Rhyme.new(endings.last).get_top_rhyme(potential_words: @related.words))
          else
            endings.push(@related.related_word(endings.last))
          end
        rescue Rhyme::EmptyFilteredSetError
          endings.pop
        end
      end
      endings
    end
  end
end
