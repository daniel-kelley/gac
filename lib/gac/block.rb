#
#  block.rb
#
#  Copyright (c) 2021 by Daniel Kelley
#

require 'set'

class GAC::Block
  @instance_num = {} # indexed by :block, value is 1-based block instance
  @wave_num = 0

  LCG_INCR_VAL = 12345
  @lcg_incr_val = LCG_INCR_VAL

  GAC_N16 = 16
  SUBTYPE = {
    "signal" => "signal",
    "control" => "control",
    "freq" => "control",
    "period" => "control",
    "Q" => "control",
    "logic" => "logic",
    "phase" => "count",
    "count" => "count",
    "button" => "logic",
    "knob" => "control",
  }

  InputArg = Struct.new(:block, :target)

  attr_reader :instance
  attr_reader :name
  attr_reader :block
  attr_reader :data
  attr_reader :output_name
  attr_reader :output_type

  #
  # Initialize block from specification
  #
  # Specification is either a scalar block name or a hash 'block:
  # [modifier]' where the modifier is a control subtype which specifies
  # the type of the block output.
  #
  #
  def initialize(block_spec, knob="hslider")
    @knob = knob
    @lcg_incr = false
    @table = false
    @table_pgm = false
    @modifier = nil
    expand_spec(block_spec)
    expand_properties
    @instance = self.class.instance(@block)
    @name = @block + @instance.to_s
    raise "Unknown block #{@block}" if @data.nil?
    @output_name = @name + "_out"
    if !@data['out'].nil?
      # check for malformed out spec
      raise "oops" if @data['out'].length != 1
      raise "oops" if @data['out'][0]['_'].nil?
      @output_type = @modifier || @data['out'][0]['_']
      @out = data_to_hash('out')
    else
      # no block outputs, so assume faust signal output
      @output_type = nil
      @out = nil
    end
    # key is input argument name, value is array of relevant InputArgs
    @input = {}
    # array in InputArgs in input order
    @input_args = []
    # convenience in args by name
    if !@data['in'].nil?
      @in = data_to_hash('in')
    else
      @in = nil
    end
    @subtype_inv = invert_subtype
    @widget_idx = 0
  end

  #
  # Register any outputs needed by the inputs of this block
  #
  def register_output(output)
    output_name_args = {} # for duplicate detection
    output_name_args[self.output_name]=1 # skip self loops
    avail_output_args = []
    each_input do |input_name,input_type|
      next if !output_type_name?(input_type)
      base_input_type = SUBTYPE[input_type]
      raise "missing SUBTYPE[#{input_type}] " if base_input_type.nil?
      avail_output_in = []

      each_compatible_output(output, input_type) do |itype,output_block|
        next if output_block == self # skip self loops
        iarg = InputArg.new(output_block, itype)
        avail_output_in << iarg
        if output_name_args[output_block.output_name].nil?
          avail_output_args << iarg
          output_name_args[output_block.output_name] = true
        end
      end

      if avail_output_in.length > 0
        @input[input_name] = avail_output_in
      end
    end
    if avail_output_args.length > 0
      @input_args << avail_output_args
    end
  end

  #
  # Construct a block function call
  #
  def fn_call
    args = ''
    if @input_args.length > 0
      input_names = @input_args.flatten.map { |iarg| iarg.block.output_name }
      input_args = input_names.join ','
      args = "(#{input_args})"
    end
    name + args
  end

  #
  # Construct the entire function body for a block instance
  #
  def fn_body
    s = []
    s << comment
    s << fn_call
    s << "    ="
    s << gac_call
    s << fn_with
    s
  end

  #
  # Yield the type and output block for each output compatible
  # with input_type
  #
  def each_compatible_output(output, input_type)
    raise 'oops' if !output_type_name?(input_type)
    # create set of types compatible with input_type that are present
    # in output
    types = Set.new
    compatible_types(input_type).each do |itype|
      types.add(itype) if !output[itype].nil?
    end

    # iterate across set of types and associated output blocks
    types.each do |itype|
      output[itype].each do |block|
        yield itype, block
      end
    end
  end


  #
  # Construct a conversion function that converts block output
  # to an input type. For example, if the block output is control
  # and the input is frequency, then the conversion function
  # converts control to frequency by calling 'control2freq'.
  #
  # Two conversions are required if both the output and input types
  # are subtypes of a common type (such as period and frequency).
  #
  # If there is no converion required, then simply return the output.
  #
  # input is destination, output is source
  #
  def convert_fn(input_type)
    raise 'oops' if @output_type.nil?
    if input_type == @output_type
      # same types, so no conversion
      @output_name
    elsif input_type == SUBTYPE[input_type]
      "#{@output_type}2#{input_type}(#{@output_name})"
    elsif @output_type == SUBTYPE[@output_type]
      "#{@output_type}2#{input_type}(#{@output_name})"
    elsif SUBTYPE[input_type] == SUBTYPE[@output_type]
      outer="#{SUBTYPE[input_type]}2#{input_type}"
      inner="#{@output_type}2#{SUBTYPE[@output_type]}"
      "#{outer}(#{inner}(#{@output_name}))"
    else
      raise "oops: missing conversion #{input_type} #{@output_type}"
    end
  end

  private

  def knob
    @knob
  end

  #
  # Return the next faust UI widget number
  #
  def wnum
    s = "[#{@widget_idx}]"
    @widget_idx += 1
    s
  end

  #
  # Return all the types compatible with typename including itself
  #
  def compatible_types(typename)
    a = [typename] + @subtype_inv[SUBTYPE[typename]]
    # special case: freq allows signal for frequency modulation
    a << 'signal' if typename == 'freq'
    a
  end

  #
  # Invert the SUBTYPEs such that the subtype is the key and the the
  # value is an array of associated subtypes
  #
  def invert_subtype
    h = {}
    SUBTYPE.each do |k,v|
      if h[v].nil?
        h[v] = []
      end
      h[v] << k
    end
    h
  end

  #
  # true if typename is associated with an output
  #
  def output_type_name?(typename)
    !SUBTYPE[typename].nil?
  end

  #
  # Convert a GAC library function YAML data to a hash.
  #
  def data_to_hash(key)
    h = {}
    @data[key].each do |item|
      raise 'oops' if item.keys.length != 1
      raise 'oops' if item.values.length != 1
      k = item.keys[0]
      v = item.values[0]
      raise 'oops' if !h[h].nil?
      h[k]=v
    end
    h
  end

  #
  # Create a block comment
  #
  def comment
    if output_type.nil?
      "// BLOCK #{name} #{output_name} [faust output]"
    else
      "// BLOCK #{name} #{output_name} #{output_type}"
    end
  end

  #
  # Iterate across block inputs, yielding the input name and type
  #
  def each_input
    return if @data['in'].nil? # no inputs
    @data['in'].each do |input|
      raise 'oops' if input.keys.length != 1
      raise 'oops' if input.values.length != 1
      input_name = input.keys[0]
      input_type = input[input_name]
      yield input_name, input_type
    end
  end

  #
  # Return the faust pipeline for a Table programming reader
  #
  def table_pgm_reader
    sname, smax =
      case @modifier
      when nil
        ["val","CONTROL_MAX"]
      when 'freq'
        ["freq","FREQ_MAX"]
      else
        raise "needs support for #{@modifier}"
      end
    " : hbargraph(\"#{wnum}[style:numerical]#{sname}\",0,#{smax})"
  end

  #
  # Yield the GAC library faust call arguments
  #
  def gac_args
    if @table
      yield :table, nil, nil, (@block + '_table')
    end
    if @table_pgm
      yield :table_pgm_idx, nil, nil, (@block + '_pgm_idx')
      yield :table_pgm_val, nil, nil, (@block + '_pgm_val')
      yield :table_pgm_we, nil, nil, (@block + '_pgm_we')
    end
    if @lcg_incr
      yield :lcg_incr, nil, nil,  (@block + '_lcg_incr')
    end
    scan_inputs_iter do  |input_name,input_type,input_var|
      yield :input, input_name, input_type, input_var
    end
  end

  #
  # Construct the GAC call with any required prefix and suffix
  #
  def gac_call
    s = []

    seq = ''
    args = []
    if @table
      args << @block + '_table'
    end
    if @table_pgm
      args << @block + '_pgm_idx'
      args << @block + '_pgm_val'
      args << @block + '_pgm_we'
    end
    if @lcg_incr
      args << @block + '_lcg_incr'
    end
    if !@in.nil? || args.length > 0
      s << '('
      s << (args+scan_inputs).join(',')
      s << ')'
      # makes diff to prev generated output easier
      seq = ': '
    end
    s << " #{seq}gac." + @block
    if @table_pgm
      s << table_pgm_reader
    end

    s
  end

  #
  # Scan block input list to and yield (input_name,input_type,var_name)
  # in GAC call order
  #
  def scan_inputs_iter
    partial_input = nil
    each_input do |input_name,input_type|
      #
      # partial_inputs have to be added last
      #
      if input_name == '_'
        if input_type != 'signal'
          raise "#{name}: non-signal partial application not allowed"
        end
        if !partial_input.nil?
          raise "#{name}: only one partial application allowed"
        end
        partial_input = [input_name,input_type]
      elsif !output_type_name?(input_type)
        # skip - no outputs will ever correspond to this input
      else
        yield input_name, input_type, input_name
      end
    end
    if !partial_input.nil?
      yield partial_input[0], partial_input[1], 'input'
    end
  end

  #
  # Scan block input list to construct the names of the inputs
  # to the GAC call in the order required
  #
  def scan_inputs
    gac_inputs = []
    scan_inputs_iter do |input_name,input_type,input_var|
      gac_inputs << input_var
    end
    gac_inputs
  end

  #
  # Return a clamp function on var for a given type
  #
  def clampfn(type,var)
    utype = type.upcase
    "gac.clamp((-#{utype}_MAX),#{utype}_MAX,#{var})"
  end


  #
  # Construct a faust waveform for a GAC table argument
  #
  def construct_table(arg)
    s = []
    s << "    #{arg} = waveform {"
    GAC_N16.times do
      s << "    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,"
    end
    # waveform disambiguator - otherwise the compiler will use the
    # table waveform instance for all tables. This just forces a
    # unique number for the 'dummy entry'. The '.0' forces the waveform
    # to be all floats.
    s << "    #{self.class.wavenum}.0"
    s << "    };"
    s
  end

  #
  # Construct a faust control for a GAC table program index argument
  #
  def construct_table_pgm_idx(arg)
    s = []
    s << "    #{arg}_f ="
    s << "        nentry(\"#{wnum}widx\",0,0,gac.N-1,1);"
    s << "    #{arg} = int(floor(#{arg}_f));"
    s << ""
    s
  end

  #
  # Construct a faust control for a GAC table program value argument
  #
  def construct_table_pgm_val(arg)
    context = (@modifier || @output_type).upcase
    s = []
    s << "    #{arg} ="
    s << "        nentry(\"#{wnum}wval\","
    s << "               #{context}_DEFAULT,"
    s << "               #{context}_MIN,"
    s << "               #{context}_MAX,"
    s << "               #{context}_STEP);"
    s
  end

  #
  # Construct a faust control for a GAC table program write enable argument
  #
  def construct_lcg_incr(arg)
    s = []
    s << "    #{arg} = #{self.class.lcg_incr};"
    s
  end

  #
  # Construct a faust control for a GAC table program write enable argument
  #
  def construct_table_pgm_we(arg)
    s = []
    s << "    #{arg} ="
    s << "        button(\"#{wnum}set\");"
    s
  end

  #
  # Construct a faust control for a given GAC input type
  #
  def construct_knob(label, typename, allow_inversion=false)
    a = ["_DEFAULT","_MIN","_MAX","_STEP"].map do |s|
      typename.upcase + s
    end

    # if inversion is allowed, the the control min is the
    # negative of the max
    if allow_inversion
      a[1] = "-#{a[2]}"
    end

    inp_knob = "#{knob}(\"#{wnum}#{label}\","
    inp_knob << a.join(",")
    inp_knob << ")"
    inp_knob
  end

  #
  # Construct a faust control for GAC button input type
  #
  def construct_input_button(name, type, arg)
    s = []
    s << "    #{arg} ="
    s << "        button(\"#{wnum}#{name}\");"
    s
  end

  #
  # Construct a faust control for GAC count input type
  #
  def construct_input_count(name, type, arg)
    construct_input_control(name, type, arg)
  end

  #
  # Construct a faust control for GAC Q input type
  #
  def construct_input_Q(name, type, arg)
    construct_input_control(name, type, arg)
  end

  #
  # Construct a faust control for GAC logic input type
  #
  def construct_input_logic(name, type, arg)
    s = []
    inp = []
    inp << "enable_"+name
    s << "    #{inp[0]} ="
    s << "        checkbox(\"#{wnum}enable\");"
    if !@input[name].nil?
      @input[name].each do |iarg|
        raise 'oops' if SUBTYPE[iarg.target] != "logic"
        output = iarg.block.name
        inp_name = output + "_#{name}_in"
        inp_knob = "checkbox(\"#{wnum}#{output}\")"
        s << "    #{inp_name} ="
        s << "        #{iarg.block.output_name}"
        s << "        & #{inp_knob};"
        inp << inp_name
      end
    end
    s << "    " + arg + "\n        =" + inp.join("\n        |") + ";"
    s
  end

  #
  # Construct a faust control for GAC control input type
  #
  def construct_input_control(name, type, arg)
    s = []
    inp = []
    inp << "#{name}_knob"
    s << "    #{inp[0]} ="
    s << "        " + construct_knob(name,type)+";"

    if !@input[name].nil?
      @input[name].each do |iarg|
        output = iarg.block.name
        inp_name = output + "_#{name}"
        target = iarg.target
        # special case for 'count' gain knobs to use 'control' range
        # otherwise the result would be nonsensical "count*count"
        if iarg.target == 'count'
          target = 'control'
        end
        inp_knob = construct_knob(output+'_'+name,target,true)
        inp_cvt = "    #{inp_name}_cvt = " + iarg.block.convert_fn(type)
        s << inp_cvt+';'
        s << "    #{inp_name} ="
        s << "        #{inp_name}_cvt"
        s << "        * #{inp_knob};"
        inp << inp_name
      end
    end
    sigma_var = name + '_sigma'
    s << "#{sigma_var} = " + inp.join("\n        + ") + ";"
    s << "    " + arg + " = " + clampfn(type, sigma_var) + ";"
    s
  end

  #
  # Construct a faust control for GAC freq (frequency) input type
  #
  def construct_input_freq(name, type, arg)
    construct_input_control(name, type, arg)
  end

  #
  # Construct a faust control for GAC period input type
  #
  def construct_input_period(name, type, arg)
    construct_input_control(name, type, arg)
  end

  #
  # Construct a faust control for GAC signal input type
  #
  def construct_input_signal(name, type, arg)
    s = []
    inp = []
    if !@input[name].nil?
      @input[name].each do |iarg|
        raise 'oops' if iarg.target != "signal"
        output = iarg.block.name
        inp_name = output + "_#{arg}_in"
        knob_name = output + "_#{arg}"
        inp_knob = construct_knob(knob_name,iarg.target,true)
        s << "    #{inp_name} = #{iarg.block.output_name} * #{inp_knob};"
        inp << inp_name
      end
    end
    sigma_var = arg + '_sigma'
    s << "#{sigma_var} = " + inp.join("\n        + ") + ";"
    s << "    " + arg + " = " + clampfn(type, sigma_var) + ";"
    s
  end

  #
  # Construct the GAC call environment
  #
  def fn_with
    needs_with = false
    s = []
    s << "with {"
    gac_args do |arg_type, input_name, input_type, arg_name|
      if input_name.nil?
        s << method("construct_"+arg_type.to_s).call(arg_name)
      else
        s << method("construct_"+arg_type.to_s+"_"+input_type).call(
                    input_name, input_type, arg_name)
      end
      needs_with = true
    end
    s << "};"
    s << ""
    needs_with ? s : [";"]
  end

  #
  # Expand the input block specification
  #
  def expand_spec(block_spec)
    if block_spec.is_a?(String)
      @block = block_spec
    elsif block_spec.is_a?(Hash)
      raise 'oops' if block_spec.keys.length != 1
      @block = block_spec.keys[0]
      @modifier = block_spec[@block]
      if SUBTYPE[@modifier].nil?
        raise "Unsupported modifier #{@modifier} in #{block_spec.inspect}"
      end
    else
      raise "Unsupported class '#{block_spec.class}' " +
        "for block specification #{block_spec.inspect}"
    end
    @data = GAC::Lib.data[@block]
  end

  #
  # Expand properties in the GAC library itself
  #
  def expand_properties
    # see if this block has table or table_pgm input properties
    each_input do |input_name,input_type|
      # this can only handle one of these at a time
      case input_type
      when 'table'
        raise "Only one #{input_type} allowed per block" if @table
        @table = true
      when 'table_pgm'
        raise "Only one #{input_type} allowed per block" if @table_pgm
        @table_pgm = true
      when 'lcg_incr'
        raise "Only one #{input_type} allowed per block" if @lcg_incr
        @lcg_incr = true
      end
    end
  end

  #
  # Class definitions
  #
  class<<self

    #
    # Return a new instance name for this block
    #
    def instance(block)
      instance = @instance_num[block]
      if instance.nil?
        instance = 0
      end
      instance += 1
      @instance_num[block] = instance
    end

    #
    # Return a unique number used for waveform disambiguation.  This
    # attempts to defeat a faust optimization of combining waveform
    # constructs with identical contents by using a unique value in
    # the 'dummy' waveform cell for lookup.
    #
    def wavenum
      num = @wave_num
      @wave_num += 1
      num
    end

    #
    # Return an increment value for a linear congruential generator
    # noise source. The intention is to have a unique increment for
    # each distinct noise source.
    #
    def lcg_incr
      val = @lcg_incr_val
      @lcg_incr_val += (LCG_INCR_VAL+1)
      val
    end

  end

end
