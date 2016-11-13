#!/usr/bin/env ruby
require_relative 'cal_in_the_hacks.rb'
require_relative 'seussifier.rb'

module CalInTheHacks
  class CLI
    def initialize(source: "sources/oz.txt", num_couplets: 5)
      @builder = CalInTheHacks::Builder.new(
        source: source,
        num_couplets: num_couplets
      )
      @seussifier = CalInTheHacks::Seussifier.new()
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

CalInTheHacks::CLI.new.run
