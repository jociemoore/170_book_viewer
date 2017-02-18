require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

before  do
  @contents = File.read("data/toc.txt").split("\n")
end

helpers do
  def in_paragraphs(text)
    new_substr = []
    counter = 0
    text.each_line('') do |substr|
      counter += 1
      new_substr << "<p id='paragraph_#{counter}'>#{substr}</p>"
    end
    new_substr.join
  end

  def highlight(paragraph)
    paragraph.gsub!(@query) { |str_match| "<strong>#{str_match}</strong>"}
  end
end

not_found do
  redirect "/"
end

def find_matching_paragraphs(file)
    includes_query = {}
    counter = 0
    file.each_line('') do |substr|
      counter += 1
      includes_query["paragraph_#{counter}"] = highlight(substr) if substr.include?(@query)
    end
    includes_query
end

def find_matching_chapters
  @contents.each_with_index do |title, index|
    file = File.read("data/chp#{index + 1}.txt")
    if file.include?(@query)
      @matching_results << index + 1 
      @matching_paragraphs[index + 1] = find_matching_paragraphs(file)
    end
  end
end

def set_headline
  if @matching_results.empty?
    @results_headline = "<h2 class='content-subhead'> Sorry, no matches were found. </h2>"
  else
    @results_headline = "<h2 class='content-subhead'> Results for '#{@query}'</h2>"
  end
end

get "/search" do
  @matching_results = []
  @matching_paragraphs = {}
  @query = params[:query]

  if @query
    find_matching_chapters
    set_headline
  end

  erb :search
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"
  erb :home
end

get "/chapters/:number" do
  number = params[:number]
  @chapter_title = "Chapter #{number}: #{@contents[number.to_i - 1]}"
  @chapter = File.read("data/chp#{params[:number]}.txt")
  erb :chapter
end



# Tilt - template engine wrapper; its a gem