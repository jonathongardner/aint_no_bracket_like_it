# frozen_string_literal: true

module Response
  def parse_response
    # Force update
    @parsed_response = JSON.parse(response.body)
  end
  def parsed_response
    @parsed_response ||= JSON.parse(response.body)
  end
end
