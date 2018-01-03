require "ripper"

class RubyTracer
  # TODO: Handle other languages...
  def trace(file)
    out = Ripper.sexp(file)

    funcs = find_funcs(out.last)
      .map { |func| define_func(func, file.lines) }
  rescue
    []
  end

  private

  def find_funcs(ast)
    ast.reduce([]) do |acc, ast|
      if ast.is_a?(Array)
        if ast.first == :def
          acc << ast
        else
          ast
            .select { |tree| tree.is_a?(Array) }
            .each do |sub_ast|
              acc << sub_ast if sub_ast.first == :def
              acc.concat(find_funcs(sub_ast)) if sub_ast.is_a?(Array)
            end
        end
      end
      acc
    end
  end

  def trace_func(ast)
    ast
      .reduce([]) do |acc, ast|
        if ast.is_a?(Array)
          lines = ast.last
          if lines.is_a?(Array) && lines.count == 2 && lines.first.is_a?(Integer) && lines.last.is_a?(Integer)
            acc << lines.first
          else
            acc.concat(trace_func(ast))
          end
        end
        acc
      end
      .uniq()
  end

  def define_func(ast, file_lines)
    name = ast[1][1]
    lines = trace_func(ast)

    if file_lines[lines.last].strip() == "end"
      lines << lines.last + 1
    end

    {
      name: name,
      start: lines.first,
      end: lines.last
    }
  end
end
