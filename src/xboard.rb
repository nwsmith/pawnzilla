#
# $Id$
#
# Copyright 2005-2008 Nathan Smith, Sheldon Fuchs, Ron Thomas
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# This class should work with both xboard and winboard. Call xboard/winboard
# with a command similiar to the one given blow:
# "C:\Program Files\WinBoard\winboard.exe" \
#   /fcp "c:\ruby\bin\ruby.exe c:\cygwin\home\ron\pawnzilla\src\xboard.rb
#   /fd "c:\cygwin\home\ron\pawnzilla\src"

require "network"

module XBoard
  class XBoard
    @log_file
    @client

    def initialize()
      @log_file = File.open("pawnzilla_xb.log", "w+")
      @log_file.puts "Game Started"
      @log_file.flush
      @client = Network::Client.new()
    end

    def process_cmd(command) 
      @log_file.puts "RECEIVED: " + command

      send_msg = false
      if (command == "xboard")
        send_msg = true
        msg = ""
      elsif (command[0..7] == "protover")
        send_msg = true
        msg = get_features(command[9..9])
      elsif (command[/^.\d.\d$/])
        send_msg = true
        @client.send_move(command)
        msg = "move " + @client.recieve_move()
      else
        # do nothing
      end

      if send_msg
        @log_file.puts "SENT:   " + msg
        STDOUT.puts msg
        STDOUT.flush
      else
        @log_file.puts "SENT: <NOTHING>"
      end
    end

    def get_features(ver_num)
      if (ver_num == "2")
        return "feature myname=\"Pawnzilla\" done=1"
      else
        return "feature done=1"
      end
    end
  end

  xboard_conn = XBoard.new()
  while input = STDIN.gets
    input.chop!
    xboard_conn.process_cmd(input)
  end
  
end
