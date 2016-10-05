name             'teamcity'
maintainer       'Shawn Neal'
maintainer_email 'sneal@sneal.net'
license          'Apache License, Version 2.0'
description      'Setup TeamCity agents and pull artifacts'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
ver_path = File.join(File.dirname(__FILE__), 'version.txt')
version ((IO.read(ver_path) if File.exists?(ver_path)) || '0.3.0').chomp
issues_url 'https://github.com/daptiv/teamcity/issues'
source_url 'https://github.com/daptiv/teamcity/'
recommends       'java' # ~FC053
recipe           'teamcity::agent', 'Installs an agent for a TeamCity server'
depends          'chef-sugar'
depends          'windows'
