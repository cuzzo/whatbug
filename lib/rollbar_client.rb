require "json"
require "date"
require "net/http"

class RollbarClient
  PROJECT_ROOT_RGX = /^\/app\//

  def initialize(config)
    @user = config["username"]
    @key = config["api_key"]
    @project = config["project"]
    @environment = config["environment"]
  end

  def get_error(error_id)
    item = fetch_item_by_counter_id(error_id)
    parse_trace(select_traces(item["result"]).first)
  end

  private

  def fetch_item_by_counter_id(item_id)
    item = JSON.parse(Net::HTTP.get(
      URI("https://api.rollbar.com/api/1/item_by_counter/#{item_id}/?access_token=#{@key}")
    ))
    uri = item["result"]["uri"]
    JSON.parse(Net::HTTP.get(
      URI("https://api.rollbar.com#{uri}")
    ))
  rescue
    raise "Error #{error_id} not found"
  end

  def parse_trace(trace)
    stack_trace = trace["frames"].map do |frame|
      file = frame["filename"].gsub(PROJECT_ROOT_RGX, "")
      line = frame["lineno"]
      function = frame["method"]

      {
        file: file,
        line: line,
        function: function
      }
    end

    {
      error_id: trace[:id],
      first_time: trace[:first_time],
      last_time: trace[:last_time],
      environment: trace[:environment],
      type: trace[:type],
      message: trace[:message],
      link: "https://rollbar.com/#{@user}/#{@project}/items/#{trace[:counter]}/",
      total_occurrences: trace[:total_occurrences],
      stack_trace: stack_trace.reverse()
    }
  end

  def select_traces(item)
    error = detail_error(item["id"])["result"]["instances"].first
    traces = error["data"]["body"]["trace"].present? ?
      [error["data"]["body"]["trace"]] :
      error["data"]["body"]["trace_chain"]

    return nil if traces.nil?

    traces.map do |trace|
      trace[:id] = item["id"].to_s.to_sym
      trace[:environment] = item["environment"]
      trace[:total_occurrences] = item["total_occurrences"]
      trace[:error] = error
      trace[:type] = item["level"]
      trace[:message] = item["title"]
      trace[:first_time] = Time.at(item["first_occurrence_timestamp"]).to_datetime
      trace[:last_time] = Time.at(item["last_occurrence_timestamp"]).to_datetime
      trace[:counter] = item["counter"]
      trace
    end
  end

  def detail_error(item_id)
    JSON.parse(Net::HTTP.get(
      URI("https://api.rollbar.com/api/1/item/#{item_id}/instances/?access_token=#{@key}")
    ))
  end
end
