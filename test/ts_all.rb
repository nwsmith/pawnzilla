#
#   $Id$
#
#   Copyright 2005, 2006 Nathan Smith, Sheldon Fuchs, Ron Thomas
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

# This file must be ran from the test directory or its parent.
# It runs all files beginning with the string tc_

require "find"
require "fileutils"
require 'test/unit'

pwd = FileUtils.pwd()


# Determine where we are
test_dir = File.directory?(File.join("..", "test"))
test_is_subdir = File.directory?("test")

# change into the test directory or alert that we were run from an unknown location
if (!test_dir && test_is_subdir) 
  FileUtils.cd("test")
elsif (!test_dir && !test_is_subdir)
  fail("Ran from unexpected directory. Failing")
end

# Run all tests
Find.find(FileUtils.pwd()) do |filename|
  next if filename.match("[\.-]svn") # skip svn directories
  next unless filename.split(File::SEPARATOR).last().match(/(tc_.*)\.rb/)
  require $1
end

FileUtils.cd(pwd)
