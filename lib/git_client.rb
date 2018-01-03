class GitClient
  def blame(file, line_start, line_end)
    exec("blame #{file} -L #{line_start},#{line_end}")
  end

  private

  def exec(cmd)
    `git --git-dir=#{@git_dir || ".git"} #{cmd}`
      .encode("UTF-8", {invalid: :replace})
      .lines
      .map(&:chomp)
  end
end
