#!/usr/bin/env ruby

require_relative 'sentence_builder.rb'
require_relative 'related_words.rb'
require_relative 'rhyming.rb'
require_relative 'word_types.rb'
require_relative 'seussifier.rb'

module WestSide
  class Builder
    def initialize(
      source: "#{File.dirname(__FILE__)}/sources/oz.txt",
      num_couplets: 5
    )
      @source = source
      @word_types = WestSide::WordTypes.new
      @related = WestSide::RelatedWords.new(@source, @word_types)
      @seussifier = WestSide::Seussifier.new()
      @num_couplets = num_couplets
    end

    def words_sample
      @related.words.to_a.shuffle[0...15].to_a.sort
    end

    def build(seed, seussify = false, syllables = nil)
      syllables ||= (5..11).to_a.sample
      lines = generate_lines(seed, syllables)
      return lines unless seussify
      begin
        seussified_lines = @seussifier.seussify(lines)
      rescue
        return lines
      end
      seussified_lines
    end

    def valid_words
      @related.words
    end

    def generate_lines(word, syllables)
      begin
        lines = [
          WestSide::SentenceBuilder
            .new(@source, @related, @word_types)
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
              potential_words: @related.words,
              top: 6
            )
          else
            word = @related.related_word(endings.last)
          end
          lines.push(
            WestSide::SentenceBuilder
              .new(@source, @related, @word_types)
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
