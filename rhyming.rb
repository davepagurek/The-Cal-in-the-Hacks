require 'net/http'
require 'json'

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
    @rhyming_words = JSON.parse(body)
  end

  def get_top_rhyme(used_words = {}, top: 10)
    index = rand(top)
    rhyming_words.sort_by{ |word| word[SCORE] }.reverse!

    # wont work if every word in [0..top] is in used_words
    while used_words.include?(rhyming_words[0..top][index][WORD]) do
      index = rand(top)
    end

    rhyming_words[0..top][index][WORD]
  end

  class BodyNotSetError < StandardError ; end
end
