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
      puts @related.words.to_a.sort.join(", ")
      word = gets.trim

      unless @related.words.include? word
        puts "That's not a good word :("
        return
      end

      puts generate_endings(word)
    end
  end

  def generate_endings(word)
    (@num_couplets*2 - 1).times.reduce([word]) do |endings, _|
      if endings.length.odd?
        endings.push(Rhyme.new(endings.last).get_top_rhyme)
      else
        endings.push(@related.related_word(endings.last))
      end
    end
  end
end

WestSide::CLI.new.run
