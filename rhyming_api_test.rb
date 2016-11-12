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

  def get_one_rhyme
    index = rand(rhyming_words.length)

    # keep looping until you find a word with a score of at least 250
    while rhyming_words[index][SCORE] < 250 do
      index = rand(rhyming_words.length)
    end

    rhyming_words[index]
  end

  class BodyNotSetError < StandardError ; end
end
