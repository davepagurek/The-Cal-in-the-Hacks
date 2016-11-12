require 'net/http'
require 'json'
require 'set'

SCORE = "score"
WORD = "word"

class Rhyme
  attr_accessor :body, :word, :rhyming_words

  def initialize(word)
    @word = word
  end

  def get_response
    url = URI.parse("http://rhymebrain.com/talk?function=getRhymes&word=#{word}")
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }

    @body ||= res.body
  end

  def json_rhymes
    raise BodyNotSetError if body.nil?
    @rhyming_words ||= JSON.parse(body)
  end

  def check_every_word(used_words, potential_words)
    return false unless used_words.length == potential_words

    used_words.each do |word|
      return false unless potential_words.include? word
    end

    true
  end

  def get_top_rhyme(used_words: Set.new, potential_words: Set.new, top: 10)
    get_response
    json_rhymes

    filtered_words = rhyming_words
      .select{ |one_word| potential_words.include? one_word[WORD] }
      .sort_by{ |word| word[SCORE] }.reverse!

    raise EmptyFilteredSetError if filtered_words.empty?
    raise UsedAllWords if check_every_word(used_words, filtered_words[0...top])

    while used_words.include? (val = filtered_words[0..top].sample[WORD]) do
      index = rand(top)
    end

    val
  end

  class EmptyFilteredSetError < StandardError ; end
  class BodyNotSetError < StandardError ; end
  class UsedAllWordsError < StandardError ; end
end
