require 'fileutils'
require 'mechanize'
require 'zip'

index = ARGV[0]
unless index
  puts "index url is required!"
  exit 1
end

agent = Mechanize.new
index = agent.get(index)

title = index.at("#info h2").inner_text.gsub(/\//, '')
puts title
FileUtils.mkdir(title)

input_filenames = []
files = []
index.search("#thumbnail-container .thumb-container a noscript img").each do |tb|
  img = tb[:src].gsub(/t\.nhentai/, 'i.nhentai').gsub(/(\d+)t\.(jpg|png)$/, '\1.\2')
  puts img
  basename = File.basename(img)
  input_filenames << basename
  save_to = File.join(title, basename)
  files << save_to
  agent.get(img).save(save_to)
end

Zip::File.open("#{title}.zip", Zip::File::CREATE) do |zipfile|
  input_filenames.each_with_index do |filename, i|
    # Two arguments:
    # - The name of the file as it will appear in the archive
    # - The original file, including the path to find it
    zipfile.add(filename, files[i])
  end
  zipfile.get_output_stream("myFile") { |f| f.write "myFile contains just this" }
end
