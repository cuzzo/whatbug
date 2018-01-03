require "json"
require "date"
require "net/http"
require "active_support/core_ext/hash"

class AirbrakeClient
  PROJECT_ROOT_RGX = /^\[PROJECT_ROOT\]/

  def initialize(config)
    @key = config["api_key"]
    @project_id = config["project_id"]
    @environment = config["environment"]
    @errors = @key.nil? ? [] : errors()
    @deploys = @key.nil? ? [] : deploys()
  end

  def get_error(group_id)
    parse_trace(select_traces({"id" => group_id}).first)
  end

  private

  def parse_trace(trace)
    stack_trace = (trace["backtrace"] || [])
      .reject { |trace| trace["file"].nil? }
      .map do |trace|
        file = trace["file"].gsub(PROJECT_ROOT_RGX, "")
        line = trace["line"]
        function = trace["function"]

        {
          file: file,
          line: line,
          function: function
        }
      end

    {
      error_id: trace["id"].to_sym,
      first_time: DateTime.rfc3339(trace["createdAt"]),
      last_time: DateTime.rfc3339(trace["lastNoticeAt"]),
      link: "https://airbrake.io/projects/#{@project_id}/groups/#{trace["id"]}",
      environment: trace["context"]["environment"],
      type: trace["type"],
      message: trace["message"],
      total_occurrences: trace["noticeTotalCount"],
      stack_trace: stack_trace
    }
  end

  def select_traces(group)
    notices = fetch_error(group["id"])["notices"]
    error = notices.first["errors"].first
    group["backtrace"] = error["backtrace"]
    group["type"] = error["type"]
    group["message"] = error["message"]
    [group]
  rescue
    []
  end

  def fetch_error(group_id)
    JSON.parse(Net::HTTP.get(
      URI("https://airbrake.io/api/v4/projects/#{@project_id}/groups/#{group_id}/notices?key=#{@key}")
    ))
  end
end
