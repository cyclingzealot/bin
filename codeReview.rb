

if ARGV[0].nil? or ARGV[1].nil?
    $stderr.puts "Specify path and pattern"
    puts ARGV
    exit 1
end

path=ARGV[0]
pattern=ARGV[1]

#p Dir.methods.sort

if ! Dir.exist?(path)
    $stderr.puts "#{path} does not seem to be a directory"
    exit 1
end


grepBlob = `grep --color=auto -rn #{pattern} #{path}`

results = {}
maxLength = 0

grepBlob.split("\n").each { |r|
    filePath    = r.split(':')[0]
    lineNumber  = r.split(':')[1].to_i

    length = filePath.sub(path, '').length
    maxLength = [length, maxLength].max

    if results[filePath].nil?
        results[filePath] = [lineNumber]
    else
        results[filePath].push(lineNumber)
    end
}


results.each{ |f, a|
    line_count = `wc -l "#{f}"`.strip.split(' ')[0].to_i

    puts "#{(f.sub(path, '')+':').ljust(maxLength+2)} #{(a.max.to_f/line_count.to_f * 100).round().to_s.rjust(3)}% (#{a.max}/#{line_count})"
}

