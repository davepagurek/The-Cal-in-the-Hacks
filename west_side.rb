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
      @source = source
      @related = WestSide::RelatedWords.new(@source)
      @num_couplets = num_couplets
    end

    def words_sample
      @related.words.to_a.shuffle[0..10].to_a.sort
    end

    def build(seed, syllables = nil)
      syllables ||= (5..11).to_a.sample
      generate_lines(seed, syllables)
    end

    def valid_words
      @related.words
    end

    def generate_lines(word, syllables)
      begin
        lines = [
          WestSide::SentenceBuilder
            .new(@source)
            .get_sentence(word, syllables)
        ]
      rescue SentenceBuilder::NoSentenceError
        return ["Oops, something went wrong :("]
      end

      endings = [word]
      used = Set.new
      while lines.length < @num_couplets*2 do
        if lines.empty?
          return ["Oops, something went wrong :("]
        end
        begin
          if lines.length.odd?
            word = Rhyme.new(endings.last).get_top_rhyme(
              used_words: used,
              potential_words: @related.words
            )
          else
            word = @related.related_word(endings.last)
          end
          lines.push(
            WestSide::SentenceBuilder
              .new(@source)
              .get_sentence(word, syllables)
          )
          endings.push(word)
          used.add(word)
        rescue Rhyme::EmptyFilteredSetError, SentenceBuilder::NoSentenceError
          lines.pop
          endings.pop
        end
      end
      lines
    end
  end
end
