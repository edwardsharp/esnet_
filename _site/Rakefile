require 'rubygems'
require 'rake'
require 'rdoc'
require 'date'
require 'yaml'
require 'tmpdir'
require 'jekyll'
require 'git'

desc "Generate blog files"
task :generate do
  Jekyll::Site.new(Jekyll.configuration({
    "source"      => ".",
    "destination" => "_site"
  })).process
end

desc "Generate and publish blog to gh-pages"
task :publish => [:generate] do
  Dir.mktmpdir do |tmp|
    puts "mkdir -p #{tmp}"
    puts "cp -R _site/* #{tmp}"
    puts "git checkout gh-pages"
    puts 'make sure gh-pages branch can be checked out successfully (are there errors above?)'
    puts "rm -rf *"
    puts "mv cp -R #{tmp}/* ."
    puts "git add ."
    message = "site updated at #{Time.now.utc}"
    puts "git commit -am #{message.shellescape}"
    puts "git push origin gh-pages"
    puts "git checkout master"
  end
end

task :default => :publish
