require "byebug"

class PythonTracer
  def trace(code)
    code = strip_comments(code)
    find_funcs(code)
      .map { |func| define_func(func, code) }
  rescue => e
    byebug
    []
  end

  private

  def find_funcs(code)
    funcs = code.scan(/[ \t]*def\s+[A-Za-z_][A-Za-z0-9_]*.*?\)\:/m)

    funcs = funcs
      .each_with_index
      .map do |func, index|
        name = func.split("(").first.split(" ").last

        [name, func.lines.count] + code
          .lines
          .each_with_index
          .select { |line, line_num| line.match(func.split("(").first) }
          .first
      end

    funcs
      .each_with_index
      .map do |func, index|
        if funcs.count > index + 2
          func << funcs[index + 1].last
        else
          func << code.lines.count
        end
        func
      end
  end

  def define_func(func, code)
    function_code = code.lines[func[3]...func[4]]
    indent = function_code
      .first[/^\s*/]
      .size

    close = function_code[func[1]..-1]
      .each_with_index
      .select do |line, line_num|
        line_indent = line[/^\s*/].size
        line.match(/[^\s]/) && line_indent <= indent
      end
      .first

    end_line = close.nil? ? func[4] : func[3] + close.last + func[1]
    while code.lines[end_line - 1].match(/^\s+$/) do
      end_line -= 1
    end

    {
      name: func.first,
      start: func[3] + 1,
      end: end_line
    }
  end

  def strip_comments(code)
    block_captures.each do |block_capture|
      matches = code.scan(block_capture[:regex])
      matches.each do |match|
        code = code.gsub(match, "#{block_capture[:start]} #{block_capture[:type]}" + "\n" * (match.lines.count - 1) + block_capture[:end])
      end
    end

    line_captures.each do |line_capture|
      code = code.gsub(line_capture[:regex], "#{line_capture[:start]} #{line_capture[:type]}")
    end

    code.tr("\t", " ")
  end

  def line_captures()
    [
      {
        regex: /#.*/,
        type: "LINE COMMENT",
        start: "#"
      }
    ]
  end

  def block_captures()
    [
      {
        regex: /\/\'''.*?\'''\//m,
        type: "BLOCK QUOTE",
        start: "'''",
        end: "'''"
      }
    ]
  end
end
