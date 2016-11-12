#!/usr/bin/env ruby

require 'delegate'
require 'matrix'
require 'tf-idf-similarity'

require 'glove'

module WestSide
  def self.preprocess

    # See documentation for all available options
    model = Glove::Model.new

    # Next feed it some text.
    text = File.read('sources/gatsby.txt')
    model.fit(text)

    # Or you can pass it a Glove::Corpus object as the text argument instead
    corpus = Glove::Corpus.build(text)
    model.fit(corpus)

    # Finally, to query the model, we need to train it
    model.train

    # So far, word similarity and analogy task methods have been included:
    # Most similar words to quantum
    puts model.most_similar('gold')
    # => [["physic", 0.9974459436353388], ["mechan", 0.9971606266531394], ["theori", 0.9965966776283189]]

    # What words relate to atom like quantum relates to physics?
    #model.analogy_words('quantum', 'physics', 'atom')
    # => [["electron", 0.9858380292886947], ["energi", 0.9815122410243475], ["photon", 0.9665073849076669]]

    # Save the trained matrices and vectors for later usage in binary formats
    #model.save('corpus.bin', 'cooc-matrix.bin', 'word-vec.bin', 'word-biases.bin')

    # Later on create a new instance and call #load
    #model = Glove::Model.new
    #model.load('corpus.bin', 'cooc-matrix.bin', 'word-vec.bin', 'word-biases.bin')
    # Now you can query the model again and get the same results as above

    #matrix = TfIdfSimilarity::TfIdfModel.new(
      #Dir.glob("sources/**/*.txt").map do |file|
        #TfIdfSimilarity::Document.new(File.read(file))
      #end
    #).similarity_matrix
  end
end

WestSide.preprocess
