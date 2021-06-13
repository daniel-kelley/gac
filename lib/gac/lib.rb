#
#  lib.rb
#
#  Copyright (c) 2021 by Daniel Kelley
#
# frozen_string_literal: true

require 'yaml'
require 'pp'

#
# GAC Faust library metadata reader
#
class GAC::LibReader
  attr_reader :data

  GAC_LIB = "#{File.dirname(__FILE__)}/../gac.lib"

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
    # pp @data
    puts @data.to_yaml
  end

  private

  #
  # Read embedded YAML in faust GAC library
  #
  def read_gac_lib
    h = {}
    y = String.new('')
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
        if arg[0] == '.' # really '...'
          yload(h, y)
          state = :search
        else
          y << "#{arg}\n"
        end
      else
        raise 'oops'
      end
    end
    h.freeze
  end

  #
  # Load YAML fragment frag into hash
  #
  def yload(hash, frag)
    block = YAML.safe_load(frag)
    k = block.keys
    raise "#{block.inspect} misformatted" if k.length != 1
    raise "duplicate key #{k[0]}" unless hash[k[0]].nil?

    hash.merge!(block)
  rescue StandardError
    pp(frag)
    raise $ERROR_INFO.to_s
  end
end

GAC::Lib = GAC::LibReader.new
