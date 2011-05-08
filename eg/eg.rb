
require "rubygems"
require "graphviz"

TRANSITION_MAPPING = {
  "t1" => "Fahre2", 
  "t2" => "Fahre3",
  "t3" => "Fahre2R",
  "t4" => "Fahre1R",
  "t5" => "Anhalten2",
  "t6" => "Öffne2",
  "t7" => "Schliesse2",
  "t8" => "Haltewünschen2",
  "t9" => "Fahre3'",
  "t10" => "Anhalten2R",
  "t11" => "Öffne2R",
  "t12" => "Schliesse2R",
  "t13" => "Haltewünschen2R",
  "t14" => "Fahre2R'",
  "t15" => "Anhalten1R",
  "t16" => "Öffne1R",
  "t17" => "Schliesse1R",
  "t18" => "Haltewünschen1R",
  "t19" => "Fahre1R'",
  "t20" => "Anhalten1",
  "t21" => "Öffne1",
  "t22" => "Schliesse1",
  "t23" => "Haltewünschen1",
  "t24" => "Fahre2'"
}

class Position
  attr_accessor :name, :id, :values
  attr_accessor :node # for gv

  def initialize(name, id, values)
    @name = name
    @id = id
    @values = values
  end

  def ==(position)
    return @name == position.name && @id == position.id && @values == position.values
  end
end

class Transition
  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def label
    return TRANSITION_MAPPING[name]
  end
end

def read_position(line)
  return Position.new($1, $2, $3.strip.split(/\s+/)) if line =~ /(M[0-9]+):\s*([0-9]+)\s*\(([^)]+)\)/

  nil
end

def read_transition(line)
  return Transition.new($1) if line =~ /---\s*(t[0-9]+)\s*--->/

  nil
end

graph = GraphViz.new(:G, :type => "digraph", :strict => true)
gv_nodes = {}

current_position = nil

open("eg.txt").each do |line|
  transition = read_transition line.strip
  position = read_position line.strip

  current_position = position if transition.nil?

  if current_position && transition && position && transition.label
    gv_current_position = gv_nodes[current_position]
    gv_position = gv_nodes[position]

    unless gv_current_position
      gv_current_position = gv_nodes[current_position] = graph.add_node(current_position.name)
    end

    unless gv_position
      gv_position = gv_nodes[position] = graph.add_node(position.name)
    end

    graph.add_edge gv_current_position, gv_position, :label => transition.label
  end
end

graph.output :png => "eg.png"

