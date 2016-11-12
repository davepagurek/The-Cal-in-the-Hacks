#!/usr/bin/env ruby

require 'delegate'
require 'matrix'
require 'tf-idf-similarity'

document1 = TfIdfSimilarity::Document.new("The quick brown fox jumped over the lazy dog")
document2 = TfIdfSimilarity::Document.new("The dog jumped over the moon")
document3 = TfIdfSimilarity::Document.new("The fox jumped over the moon")
document4 = TfIdfSimilarity::Document.new("The dog is quick")

corpus = [document1, document2, document3, document4]
model = TfIdfSimilarity::TfIdfModel.new(corpus)

matrix = model.similarity_matrix
puts matrix[model.document_index(document2), model.document_index(document3)]
puts matrix[model.document_index(document2), model.document_index(document4)]

#tfidf_by_term = {}
#document1.terms.each do |term|
  #tfidf_by_term[term] = model.tfidf(document1, term)
#end
#puts tfidf_by_term.sort_by{|_,tfidf| -tfidf}
