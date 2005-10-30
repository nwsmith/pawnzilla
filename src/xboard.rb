#
#   $Id$
#
#   Copyright 2005 Nathan Smith, Sheldon Fuchs
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
#
# POC code
# This should work with both xboard and winboard.

# exucte with a command like the following:
#
# "C:\Program Files\WinBoard\winboard.exe" /fcp "c:\ruby\bin\ruby.exe c:\cygwin\home\ron\pawnzilla\src\xboard.rb
module XBoard
	f = open("game_rb.log", "w+");
	while xboardInput = STDIN.gets
		xboardInput.chop!
		f.puts ">" + xboardInput

		if (xboardInput == "xboard")
			f.puts("<");
			STDOUT.puts
		elsif (xboardInput == "protover 2")
			f.puts("<feature myname=\"Pawnzilla\"");
			STDOUT.puts("feature myname=\"Pawnzilla\"");
			f.puts("<feature done=1");
			STDOUT.puts("feature done=1");
		elsif (xboardInput[/.\d.\d/])
			f.puts("<move d7d5");
			STDOUT.puts("move d7d5");
		end
		STDOUT.flush
	end
	f.close
end
