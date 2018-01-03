require "linguist"

require_relative "ruby_tracer"
require_relative "c_syntax_tracer"
require_relative "python_tracer"

class VirtualBlob < Linguist::FileBlob
  def initialize(path, data)
    @path = path
    @data = data
  end

  def data
    @data
  end

  def size
    @size ||= data.length
  end
end

class Tracer
  def trace(path, code)
    case recognize(path, code)
    when "ruby"
      RubyTracer.new.trace(code)
    when "php", "javascript"
      CSyntaxTracer.new.trace(code)
    when "python"
      PythonTracer.new.trace(code)
    else
      []
    end
  end

  private

  def recognize(path, code)
    Linguist
      .detect(VirtualBlob.new(path, code))
      &.name
      &.downcase
  end
end
