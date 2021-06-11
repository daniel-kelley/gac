#
#  lib.rb
#
#  Copyright (c) 2021 by Daniel Kelley
#

require 'yaml'
require 'pp'

class GAC::LibReader

  attr_reader :data

  GAC_LIB = File.dirname(__FILE__) + "/../gac.lib"

  #
  # Init GAC
  #
  def initialize
    @data = read_gac_lib
  end

  #
  # Show library info
  #
  def info
    #pp @data
    puts @data.to_yaml
  end

  private

  #
  # Read embedded YAML in faust GAC library
  #
  def read_gac_lib
    h = {}
    y = ""
    state = :search
    IO.foreach(GAC_LIB) do |line|
      case state
      when :search
        if line =~ %r{^// ---}
          y.clear
          state = :collect
        end
      when :collect
        line =~ %r{^//\s(.*)}
        arg = $1
        if arg[0] == '.' # really ...
          begin
            block = YAML::load(y)
            k = block.keys
            raise "#{block.inspect} misformatted" if k.length != 1
            raise "duplicate key #{k[0]}" if !h[k[0]].nil?
            h.merge!(block)
          rescue
            pp(y)
            raise "#{$!}"
          end
          state = :search
        else
          y << arg+"\n"
        end
      else
        raise 'oops'
      end
    end
    h
  end

end

GAC::Lib = GAC::LibReader.new
