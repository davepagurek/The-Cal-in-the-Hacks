require 'set'

module WestSide
  class WordTypes
    attr_reader :adjectives, :adverbs, :articles, :conjs, :inters, :nouns, :preps, :pros, :verb_i, :verb_t

    def initialize
      @adjectives = File.read("sources/data/adj").split(/\s+/).map(&:downcase).to_set
      @adverbs = File.read("sources/data/adv").split(/\s+/).map(&:downcase).to_set
      @articles = File.read("sources/data/article").split(/\s+/).map(&:downcase).to_set
      @conjs = File.read("sources/data/conj").split(/\s+/).map(&:downcase).to_set
      @inters = File.read("sources/data/inter").split(/\s+/).map(&:downcase).to_set
      @nouns = File.read("sources/data/noun").split(/\s+/).map(&:downcase).to_set
      @preps = File.read("sources/data/prep").split(/\s+/).map(&:downcase).to_set
      @pros = File.read("sources/data/pro").split(/\s+/).map(&:downcase).to_set
      @verb_i = File.read("sources/data/verb_i").split(/\s+/).map(&:downcase).to_set
      @verb_t = File.read("sources/data/verb_t").split(/\s+/).map(&:downcase).to_set

      @all = [@adjectives, @adverbs, @articles, @conjs, @inters, @nouns, @preps, @pros, @verb_i, @verb_t]
    end

    def type_of(word)
      return "adjective" if @adjectives.include? word.downcase
      return "adverb" if @adverbs.include? word.downcase
      return "articles" if @articles.include? word.downcase
      return "conj" if @conjs.include? word.downcase
      return "inter" if @inters.include? word.downcase
      return "noun" if @nouns.include? word.downcase
      return "prep" if @preps.include? word.downcase
      return "pro" if @pros.include? word.downcase
      return "verb" if @verb_t.include?(word.downcase) || @verb_i.include?(word.downcase)
      nil
    end

    def valid?(word)
      !!type_of(word)
    end
  end
end
