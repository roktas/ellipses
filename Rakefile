# frozen_string_literal: true

require 'rake/clean'

require 'rubocop/rake_task'
RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = ['--display-cop-names']
end

desc 'Lint code'
task lint: :rubocop

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.libs.push 'test'
  t.test_files = FileList['test/client/**/*.rb', 'test/server/**/*.rb']
end

task :test do # rubocop:disable Rake/Desc
  warn ''
  warn 'Running integration tests'
  warn ''
  sh '.local/bin/test'
end

require 'rubygems/tasks'
Gem::Tasks.new console: false do |tasks|
  tasks.push.host = ENV['RUBYGEMS_HOST'] || Gem::DEFAULT_HOST
end

CLEAN.include('*.gem', 'pkg')

if Dir.exist? 'man'
  desc 'Generate manual pages'
  task :man do
    sh 'cd man/tr && ronn *.ronn' if Dir.exist? 'man/tr'
    sh 'cd man/en && ronn *.ronn' if Dir.exist? 'man/en'
  end
  CLEAN.include('man/**/*[0-9].html')
  CLOBBER.include('man/**/*.[0-9]')
else
  task :man  # rubocop:disable Rake/DuplicateTask
end

desc 'Bump version (use "major", "minor", "patch", "pre" or "auto")'
task :bump do
  Bumper.bump ARGV[1]
  exit
end

task default: %i[lint test]

class Bumper
  Version = Struct.new :major, :minor, :patch, :pre do
    def to_s
      [major, minor, patch].join('.') + (pre ? ".#{pre}" : '')
    end

    def newer?(other)
      return true if !other || other.empty?

      Gem::Version.new(to_s) > Gem::Version.new(other.to_s)
    end

    def self.parse(string)
      new(*string.strip.gsub(/^v?/, '').split('.', 4))
    end

    private_class_method :new
  end

  def self.bump(arg, version_file = 'VERSION')
    new(version_file).bump(arg)
  end

  attr_reader :latest, :current

  def initialize(version_file = 'VERSION')
    git_ensure_clean

    @version_file = version_file
    @current = Version.parse File.read(version_file)
    @latest = Version.parse git_latest_tag
  end

  def bump(arg)
    self.current = new_version(arg)
    commit(update_version_file, *update_ruby_sources)
  end

  private

  attr_reader :version_file
  attr_writer :current

  def new_version(arg = nil)
    return bump_by_auto if !arg || arg == 'auto'

    if %i[major minor patch pre].include? arg.to_sym
      bump_by_part(arg)
    else
      bump_by_manual(arg)
    end
  end

  def bump_by_part(part)
    target = (new_version = current.dup).send part
    new_version.send "#{part}=", target&.succ
    new_version
  end

  def bump_by_manual(new_string)
    Version.parse new_string
  end

  def bump_by_auto
    Version.parse current.to_s.succ
  end

  def write_version(file, version)
    content = File.read(file)
    content.gsub!(/^(\s*)VERSION(\s*)= .*?$/, "\\1VERSION = '#{version}'")
    raise "Could not insert VERSION in #{file}" unless Regexp.last_match

    File.open(file, 'w') { |f| f.write content }
  end

  def update_ruby_sources
    updated = []
    FileList['**/version.rb'].each do |file|
      warn "Updating #{file} for the new version: #{current}"
      write_version(file, current.to_s)
      updated << file
    end
    updated
  end

  def update_version_file
    warn "Updating #{version_file} for the new version: #{current}"
    File.write(version_file, "#{current}\n")
    version_file
  end

  def commit(*files)
    if current.newer?(latest)
      git_commit("Bump version to #{current}", *files)
    else
      warn "version #{current} is not newer than #{latest}; skipping commit"
    end
  end

  def git_latest_tag
    tag = `git describe --abbrev=0 --tags 2>/dev/null`
    warn 'No tag found; make a release first.' unless tag
    tag
  end

  def git_commit(message, *files)
    system('git', 'commit', '-m', message, *files) || abort('Git commit failed')
  end

  def git_ensure_clean
    return if `git status --untracked-files=no --porcelain`.strip.empty?

    abort 'There are uncommitted changes in the repository.'
  end
end
