require 'csv'
require 'byebug'

filePath=ARGV[0]

if not File.exists?(filePath)
    $stderr.puts "No file at #{filePath}"
    exit 1
end

CSV.open(filePath, 'rb', headers: :first_row, encoding: 'UTF-8', col_sep: "\t") do |csv|
    currentModel = ''
    railsGstr = ''
    line_count = File.readlines(filePath).size
    linenum = 0
    csv.read.each do |row|
        linenum += 1
        next if (row['model'].nil? or row['model'].empty?)
        if row['model'] != currentModel
            puts railsGstr if railsGstr != ''
            currentModel = row['model']
            railsGstr = "rails g #{currentModel} "
        end

        railsGstr += row['attribute'] + ':' + row['datatype'] + ' '

        puts railsGstr if linenum == line_count
    end
end
