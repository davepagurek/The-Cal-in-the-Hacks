#!/usr/bin/env ruby

require_relative 'sentence_builder.rb'
require_relative 'related_words.rb'
require_relative 'rhyming.rb'

module WestSide
  class CLI
    def initialize(source: "sources/gatsby.txt", num_couplets: 5)
      @related = WestSide::RelatedWords.new(source)
      @num_couplets = num_couplets
    end

    def run
      puts "Pick a seed word:"
      puts @related.words.to_a.shuffle[0..10].to_a.sort.join(", ")
      word = gets.strip

      unless @related.words.include? word
        puts "That's not a good word :("
        return
      end

      puts generate_endings(word)
    end

    def generate_endings(word)
      endings = [word]
      while endings.length < @num_couplets do
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
      puts endings
    end
  end
end

WestSide::CLI.new.run
