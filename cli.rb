#!/usr/bin/env ruby
require_relative 'west_side.rb'
require_relative 'seussifier.rb'

module WestSide
  class CLI
    def initialize(source: "sources/oz.txt", num_couplets: 5)
      @builder = WestSide::Builder.new(
        source: source,
        num_couplets: num_couplets
      )
      @seussifier = WestSide::Seussifier.new()
    end

    def run
      puts "Pick a seed word:"
      puts @builder.words_sample.join(", ")
      word = gets.strip

      unless @builder.valid_words.include? word
        puts "That's not a good word :("
        return
      end

      syllables = (5..10).to_a.sample
      rap = @builder.build(word, syllables)
      rap = @seussifier.seussify(rap)
      puts rap
    end
  end
end

WestSide::CLI.new.run
