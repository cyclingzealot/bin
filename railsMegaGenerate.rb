require 'csv'
require 'byebug'
require 'optparse'
require 'facets'

filePath=ARGV[0]

params = ARGV.getopts("hc", "change", "file:", "help")

# Show help if requested or the file parameter is not specified
if params.slice(:h, :help).count > 0 or params.slice(":file", ":f").count == 0
    puts "Usage: -f $filePath [-c[hange]]"
    exit 1
end


def detectSeperator(filePath)
    firstLine = File.open(filePath, &:readline)
    [',', ":", ";", "\t"].max_by{|s| firstLine.split(s).count}
end


if not File.exists?(filePath)
    $stderr.puts "No file at #{filePath}"
    exit 1
end

sep=detectSeperator(filePath)
CSV.open(filePath, 'rb', headers: :first_row, encoding: 'UTF-8', col_sep: sep) do |csv|
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

        railsGstr += row['attribute'] + ':' + row['datatype']

        railsGstr += ':uniq' if ['VRAI', 'TRUE'].include?(row['unique'])

        railsGstr += ' '

        puts railsGstr if linenum == line_count
    end
end
