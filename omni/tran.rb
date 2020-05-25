argcount = 0
ARGV.each {|arg|
           argcount += 1
         }
if argcount != 2 then
  $stderr.puts "Two File Names Required"
  exit(1)
end
infile = File.new(ARGV[0].to_s, "r")
outfile = File.new(ARGV[1].to_s, "w")
while str = infile.gets
   outfile.puts(str)
end
