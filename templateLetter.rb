#! /usr/bin/ruby

require 'byebug'

### First let's make sure there is a membershil list
if ARGV[0].nil? or ARGV[1].nil? or ['-h', '--help'].include?(ARGV[0]) then
    $stderr.puts "I need the full path of the template file and data file"
    #$stderr.puts "First column of the data file is used as key to name letters stored in /tmp/"
    exit 1
end

templatePath=ARGV[0]
dataPath=ARGV[1]

[templatePath, dataPath].each{|filePath|
    if ! File.file?(filePath)
        $stderr.puts "There does not seem to be a file at #{filePath}"
        exit 1
    end
}




require 'csv'


seperator="\t"
if ! ENV['sep'].nil?
    seperator= ENV['sep']
end


headers = []
data = []
rowCount = 0
File.foreach(dataPath) {|l|
    rowFile = CSV.parse_line(l, :col_sep => seperator).collect{|x|
        if ! x.nil?
            x.strip;
        end
    }
    if rowCount ==0
        headers = rowFile
    else
	    row = {}
	    headers.each_with_index {|header, index|
	        row[header] = rowFile[index]
	    }

	    data.push(row)
    end

    rowCount += 1
}



templateStr = File.read(templatePath)

data.each { |r|
    message = templateStr.clone

    r.each{|key,value|
        value = '' if value.nil?
        message.sub!('%'+key+'%', value)
    }

    puts message
}
