#!/usr/bin/env ruby
# encoding: utf-8
# -----------------------------------------------------------------------------
# semver_helper.rb
#
# Author:: Shawn Weitzel (<sweitzel@daptiv.com>)
#
# Copyright (c) 2014 Daptiv Solutions LLC.
# All rights reserved - Do Not Redistribute
#
# A script to help automate semantic versioning of github based repositories
# and assumes ssh key and auth is already setup for Github connections from
# this host.
# -----------------------------------------------------------------------------

gems = %w(fileutils json octokit rest-client)
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

require 'optparse'

def parse_command_line_options
  command_line_options = {}
  OptionParser.new do |opts|
    opts.banner = 'Usage: semver_helper.rb [options]'
    opts.on('-a', '--access_token ACCESS_TOKEN',
            'The Github access token') do |access_token|
      command_line_options[:access_token] = access_token
    end
    opts.on('-r', '--repository REPOSITORY',
            'The Github repository: user/reponame') do |repository|
      command_line_options[:repo] = repository
    end
    opts.on('-b', '--branch BRANCH', 'The repository branchname') do |branch|
      command_line_options[:branch] = branch
    end
    opts.on('-t', '--teamcity', 'Format output for TeamCity') do
      command_line_options[:tc_format] = true
    end
    opts.on('-h', '--help', 'Display this screen') do
      puts opts
      exit
    end
  end.parse!
  command_line_options
end

def connect_to_github(command_line_options)
  Octokit.configure do |c|
    fail 'No Access Token passed' if command_line_options[:access_token].nil?
    c.access_token = command_line_options[:access_token]
  end
end

def retrieve_current_semver(repo)
  all_the_tags = get_all_tags_from_github(repo)
  if all_the_tags.empty?
    return create_starting_tag(repo)
  else
    valid_semver_tags = Array[]
    semver_pattern = %r{
      ^(?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*)
      (?:-(?:0|[1-9A-Za-z\-][\dA-Za-z\-]*)
        (?:\.(?:0|[1-9A-Za-z\-][\dA-Za-z\-]*))*)?
      (?:\+[\dA-Za-z\-]+(?:\.[\dA-Za-z\-]+)*)?$
    }x
    all_the_tags.each do |hash|
      valid_semver_tags.push(hash) if hash[:name] =~ semver_pattern
    end
  end
  if valid_semver_tags.empty?
    # When on any branch and no valid semvar tag exists on repo,
    # Then release '0.1.0' will be created on master
    return create_starting_tag(repo)
  else
    return max_semver(valid_semver_tags)
  end
end

def max_semver(tag_array)
  max_major = 0
  tag_array.each do |hash|
    current_major = hash[:name].split('.')[0].to_i
    if current_major > max_major
      max_major = current_major
    end
  end
  max_minor = 0
  tag_array.each do |hash|
    if hash[:name].split('.')[0].to_i == max_major
      current_minor = hash[:name].split('.')[1].to_i
      if current_minor > max_minor
        max_minor = current_minor
      end
    end
  end
  max_patch = 0
  tag_array.each do |hash|
    if hash[:name].split('.')[0].to_i == max_major
      if hash[:name].split('.')[1].to_i == max_minor
        current_patch = hash[:name].split('.')[2].to_i
        if current_patch > max_patch
          max_patch = current_patch
        end
      end
    end
  end
  max_semver = "#{max_major}.#{max_minor}.#{max_patch}"
  return max_semver
end

def get_all_tags_from_github(repo)
  Octokit.tags(repo)
  last_response = Octokit.last_response
  tag_array = last_response.data
  loop do
    break if last_response.rels[:next].nil?
    last_response = last_response.rels[:next].get
    tag_array += last_response.data
  end
  tag_array
end

def create_starting_tag(repo)
  starting_tag = '0.1.0'
  create_new_tag(starting_tag, repo, retieve_last_commit_sha_from_master(repo))
  starting_tag
end

def retrieve_last_commit_sha_from_branch(repo, branch_name)
  commits_option = { sha: branch_name }
  Octokit.commits(repo, commits_option)
  Octokit.last_response.data.first[:sha]
end

def retieve_last_commit_sha_from_master(repo)
  retrieve_last_commit_sha_from_branch(repo, 'master')
end

def create_new_tag(tag, repo, object_sha)
  message = "Creating new tag #{tag} on #{repo} for commit sha #{object_sha}"
  tag_date = DateTime.now.to_s
  newtag = Octokit.create_tag(repo, tag, message, object_sha, 'commit',
                              'Semver Helper', 'dl_teambork@daptiv.com',
                              tag_date)
  Octokit.create_ref(repo, "tags/#{newtag[:tag]}", newtag[:sha])
end

def retrieve_commit_parents(repo)
  last_commit = Octokit.commit(repo, 'master')
  last_commit[:parents]
end

def retrieve_pull_request(repo, branch, state)
  begin
    branch_object = Octokit.branch(repo, branch)
    rescue
      if branch_object.nil?
        raise "Could not find branch: #{branch}, please check spelling and case"
      end
  end
  Octokit.pull_requests(repo, options = { state: state,
                                          direction: 'asc',
                                          per_page: 100 })
  last_response = Octokit.last_response
  pull_request_array = last_response.data
  loop do
    break if last_response.rels[:next].nil?
    last_response = last_response.rels[:next].get
    pull_request_array += last_response.data
  end
  pull_request_array.each do |pull_request|
    if branch == 'master'
      commit_parent_array = retrieve_commit_parents(repo)
      commit_parent_array.each do |commit_parent|
        return pull_request if pull_request[:head][:sha] == commit_parent[:sha]
      end
    else # not on master
      if pull_request[:head][:sha] == branch_object[:commit][:sha]
        return pull_request
      end
    end
  end
  nil # No pull request matched the current commit
end

def update_feature_branch_semver(repo, branch, pull_request, semver_to_update)
  Octokit.compare(repo, 'master', branch)
  commit_count = Octokit.last_response.data[:total_commits].to_s.rjust(5, '0')
  prerelease_suffix = "-PR#{pull_request[:number].to_s.rjust(5, '0')}" \
                      "C#{commit_count}"
  semver_array = semver_to_update.split('.')
  if pull_request[:body].lines.first
    change_type = pull_request[:body].lines.first.strip
  end
  case change_type
  when 'MAJOR'
    new_major_version = semver_array[0].to_i + 1
    semver_body = "#{new_major_version}.0.0"
  when 'MINOR'
    new_minor_ver = semver_array[1].to_i + 1
    semver_body = "#{semver_array[0]}.#{new_minor_ver}.0"
  else
    new_patch_version = semver_array[2].to_i + 1
    semver_body = "#{semver_array[0]}." \
                  "#{semver_array[1]}." \
                  "#{new_patch_version}"
  end
  semver_body + prerelease_suffix
end

def output_semver(options, semver)
  if options[:tc_format] == true
    puts "##teamcity[buildNumber '#{semver}']"
    puts "##teamcity[setParameter name='env.SEMVER' value='#{semver}']"
  else
    puts semver
  end
end

def get_constructed_semver(repo, branch, current_semver)
  constructed_semver = nil
  # -----------------------------------------------------------------------------
  # When on feature branch with no associated pull request,
  # Then version will not be set

  if branch != 'master' && branch != "release"
    feature_pull_request = retrieve_pull_request(repo,
                                                 branch,
                                                 'open')
    if feature_pull_request.nil?
      fail "No pull request found for #{repo}, #{branch}"
    else
      # --------------------------------------------------------------------------
      # When on feature branch with associated pull request,
      # Then version will be constructed from latest valid semvar tag on master
      # by incrementing patch value and appending prerelease information
      # in the following regex format:
      # ^v(?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*)-PR\d{5}C\d{5}$
      constructed_semver = "#{update_feature_branch_semver(
                                           repo,
                                           branch,
                                           feature_pull_request,
                                           current_semver)}"
    end
  else # We are on master or release

    # ----------------------------------------------------------------------------
    # When on master and no commits since last valid semver tag,
    # Then version will same as latest valid tag
    Octokit.compare(repo, current_semver, branch)
    if Octokit.last_response.data[:total_commits] == 0
      constructed_semver = current_semver
    else
      # --------------------------------------------------------------------------
      # When on master and new commits since last valid semver tag,
      # and commits are from a Pull Request merge,
      # Then version will be constructed from latest valid semver tag on master
      # by incrementing major, minor or patch(default) value based on specific
      # strings on the first line of the Pull Request comments:
      # 'MAJOR' or 'MINOR' will cause major or minor increments
      # blank or any other text will use the default of a patch increment
      master_or_release_pull_request = retrieve_pull_request(repo,
                                                  branch,
                                                  'closed')
      if !master_or_release_pull_request.nil?
        semver_array = current_semver.split('.')

        if master_or_release_pull_request[:body].lines.first
          change_type = master_or_release_pull_request[:body].lines.first.strip
        end

        case change_type
        when 'MAJOR'
          new_major_version = semver_array[0].to_i + 1
          semver_body = "#{new_major_version}.0.0"
        when 'MINOR'
          new_minor_ver = semver_array[1].to_i + 1
          semver_body = "#{semver_array[0]}.#{new_minor_ver}.0"
        else
          new_patch_version = semver_array[2].to_i + 1
          semver_body = "#{semver_array[0]}." \
                        "#{semver_array[1]}." \
                        "#{new_patch_version}"
        end
        constructed_semver = semver_body
      else # No pull request for last commit on master or release
        # ------------------------------------------------------------------------
        # When on master or release and new commits since last valid semver tag,
        # and commits are not from a Pull Request merge,
        # Then version will be constructed from latest valid semvar tag on master
        # by incrementing patch value
        semver_array = current_semver.split('.')
        new_patch_version = semver_array[2].to_i + 1
        constructed_semver = "#{semver_array[0]}." \
                             "#{semver_array[1]}." \
                             "#{new_patch_version}"
      end

      sha = retrieve_last_commit_sha_from_branch(repo, branch)
      # --------------------------------------------------------------------------
      # When on master or release and new constructed version is generated,
      # Then tag with new constructed version will be created on master or release
      create_new_tag(constructed_semver, repo, sha)
    end
  end
  constructed_semver
end
# -----------------------------------------------------------------------------
# Main Program start
#

command_line_options = parse_command_line_options

connect_to_github(command_line_options)

latest_semver = retrieve_current_semver(command_line_options[:repo])

next_semver = get_constructed_semver(command_line_options[:repo],
                                     command_line_options[:branch],
                                     latest_semver)

output_semver(command_line_options, next_semver)
