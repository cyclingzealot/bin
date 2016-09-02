require 'byebug'
require 'shellwords'
require 'date'

if ARGV[0].nil? or ARGV[1].nil? or ARGV[2].nil?
    $stderr.puts "Specify path, pattern and start date"
    puts ARGV
    exit 1
end

path=ARGV[0]
pattern=ARGV[1]
dateStart=ARGV[2]

#p Dir.methods.sort

if ! Dir.exist?(path)
    $stderr.puts "#{path} does not seem to be a directory"
    exit 1
end


grepBlob = `grep --color=auto -rn -e #{pattern.shellescape} #{path}`

#$stderr.puts "#{grepBlob.split("\n").count} results found"

results = {}
maxLength = 0

grepBlob.force_encoding("iso-8859-1").split("\n").each { |r|
    filePath    = r.split(':')[0].strip
    lineNumber  = r.split(':')[1].to_i

    next if filePath.include?('.sw')

    length = filePath.sub(path, '').length
    maxLength = [length, maxLength].max

    if results[filePath].nil?
        results[filePath] = [lineNumber]
    else
        results[filePath].push(lineNumber)
    end
}

fileBlob = `find #{path}/* -type f`

fileBlob.split("\n").each { |r|
    filePath = r.strip

    if results[filePath].nil?
        results[filePath] = [0]
    end

    length = filePath.sub(path, '').length
    maxLength = [length, maxLength].max

}

lastRow = "At this rate we will be finished:"

maxLength = [lastRow.length, maxLength].max

results = results.sort_by{ |f, a|
    #line_count = `wc -l "#{f}"`.strip.split(' ')[0].to_i
    lreviewed = a.max - a.min
    lreviewed
}.reverse

totalLineCount      = 0
totalLinesReviewed   = 0

results.each{ |f, a|
    line_count      = `wc -l "#{f}"`.strip.split(' ')[0].to_i
    totalLineCount += line_count

    lreviewed           = a.max - a.min
    totalLinesReviewed   += lreviewed

    puts "#{(f.sub(path, '').sub(/^\//, '') +':').ljust(maxLength+2)} #{(lreviewed.to_f/line_count.to_f * 100).round().to_s.rjust(3)}% (#{lreviewed}/#{line_count})"
}

numDays = DateTime.now - DateTime.parse(dateStart)

pace = totalLinesReviewed.to_f/numDays.to_f

finish = DateTime.now + ((totalLineCount-totalLinesReviewed) / pace)

puts
puts "#{(totalLinesReviewed/totalLineCount.to_f.to_f*100).round()} % (#{totalLinesReviewed}/#{totalLineCount})"
puts "At this rate we will be finished:".ljust(maxLength+2) + finish.strftime('%c')
