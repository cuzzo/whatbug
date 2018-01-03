class CSyntaxTracer
  def trace(code)
    code = strip_comments(code)
    find_funcs(code)
      .map { |func| define_func(func, code) }
  rescue
    []
  end

  private

  def find_funcs(code)
    funcs = code.scan(/[a-zA-Z \t]*function\s+[A-Za-z_][A-Za-z0-9_]*/)
    funcs += code.scan(/[a-zA-Z0-9_. \t]*\s*=\s*function/)

    funcs = funcs
      .each_with_index
      .map do |func, index|
        if func.match(/[a-zA-Z0-9_]*\s+=/)
          name = func
            .split("=")
            .last(2)
            .first
            .split(/[ \t.]/)
            .last
        else
          name = func.split(" ").last
        end

        [name] + code
          .lines
          .each_with_index
          .select { |line, line_num| line.match(func) }
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
    function_code = code.lines[func[2]...func[3]]
    indent = function_code
      .first
      .match(/^\s*/)[0]

    close = function_code
      .each_with_index
      .select { |line, line_num| line.match(Regexp.compile("^#{indent}}")) }
      .first

    close ||= function_code
      .each_with_index
      .map { |line, line_num| [line.match(/}/), line_num] }
      .select { |line| line.first }
      .reverse
      .first

    end_line = close.nil? ? func[3] : func[2] + close.last + 1

    {
      name: func.first,
      start: func[2] + 1,
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

    code
  end

  def line_captures()
    [
      {
        regex: /\/\/.*/,
        type: "LINE COMMENT",
        start: "//"
      }
    ]
  end

  def block_captures()
    [
      {
        regex: /\/\*.*?\*\//m,
        type: "BLOCK QUOTE",
        start: "/*",
        end: "*/"
      }
    ]
  end
end
