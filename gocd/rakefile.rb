$stderr.sync = true
$stdout.sync = true

gems = %w(colorize)
puts 'Installing gems...'
gems.each do |g|
  begin
    gem g
  rescue Gem::LoadError
    system "gem install #{g} --no-document"
    Gem.clear_paths
  end
  require g
end

task default: [:build]

desc 'Test pipeline YAML syntax.'
task :build do
  require 'yaml'
  puts "Running YAML syntax test...\n"
  errors = []
  Dir['./*/*.yaml'].each do |pipeline|
    begin
      YAML.load_file(pipeline)
      puts "#{pipeline}... OK".green
    rescue Psych::SyntaxError => e
      puts "#{pipeline}... ERROR".red
      errors.push(e)
    end
  end

  if errors.any?
    puts "\nErrors:\n".red
    errors.each do |error|
      puts "#{error}\n".red
    end
    exit 1
  end
end
