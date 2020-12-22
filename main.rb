require 'fileutils'
require 'nkf'
require 'csv'
require 'logger'

def glob(target_dir)
  file_list = []
  Dir.glob('**/*', base: target_dir).each do |file|
    input_file_path = File.join(target_dir, file)
    file_list.push(input_file_path) unless File.directory?(input_file_path)
  end
  file_list
end

glob(ENV['TARGET_DIR']).each do |input_file_path|
  content = File.read(input_file_path)
  encode = NKF.guess(content)
  puts "#{input_file_path} => #{encode}"
  out_file_path = input_file_path.gsub(%r{^data/}, 'out/')
  out_dir_path = File.dirname(out_file_path)
  FileUtils.mkdir_p(out_dir_path) unless File.exist?(out_dir_path)
  File.open(input_file_path, 'r') do |f|
    idx = 0
    str = ''
    body = begin File.read(f, encoding: "BOM|#{encode}").encode(Encoding::UTF_8) rescue File.read(f, encoding: "BOM|#{encode}") end
    body.gsub(/\r\n/, "\n").split(/$/).each do |line|
      str << "#{line},#{ENV['EXECUTE_DATE']}" if idx != 0
      idx += 1
    end
    File.binwrite(out_file_path, str.gsub(/^\n/, ''))
  end
end
