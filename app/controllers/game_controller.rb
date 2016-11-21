require 'open-uri'
require 'json'

class GameController < ApplicationController
  def generate_grid(grid_size)
    grid = "";
    alphabet = ("A".."Z").to_a
    grid_size.times do
      grid += alphabet[Random.rand(0..25)] + " "
    end
    grid
  end

  def calc_score(attempt, grid, time)
    attempt.split("").length * 300 - 30 * grid.length - 20 * time
  end

  def are_word_chars_in_array(word, input_array)
    array = input_array
    result = word.split("").all? do |letter|
      array.include? letter.upcase
      i = array.index(letter.upcase)
      array.delete_at(i) unless i.nil?
    end
    result
  end

  def get_translation_from_systran_api(attempt)
    key = "65834db2-26d1-4387-95eb-c94ff9a9a386"
    url = "https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=#{key}&input=#{attempt}"
    JSON.parse(open(url).read)["outputs"][0]["output"]
  end

  def calc_result(time, options)
    score = 0
    translation = nil
    message = !options[:in_grid] ? "not in the grid" : "not an english word"
    if options[:in_grid] && options[:is_english]
      translation = options[:translation]
      message = "well done"
      score = options[:score] > 0 ? options[:score] : 0
    end
    { time: time, translation: translation, score: score.to_i, message: message }
  end

  def game
    @grid_string = generate_grid(9)
    @start_time = Time.now
    puts @start_time
  end

  def score
    time = Time.now - params[:start_time].to_time
    attempt = params[:answer]
    grid = params[:grid].split(" ")
    translation = get_translation_from_systran_api(attempt)
    in_grid = are_word_chars_in_array(attempt, grid)
    is_english = attempt != translation
    score = calc_score(attempt, grid, time)
    @results = calc_result(time, score: score, translation: translation, in_grid: in_grid, is_english: is_english)
  end
end
