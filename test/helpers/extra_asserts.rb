# frozen_string_literal: true

module ExtraAsserts
  # def error_raised_with_messege(error, error_message)
  #   begin
  #     yield
  #   rescue Exception => e
  #     assert_equal error, e.class, 'Should raise error'
  #     assert_equal error_message, e.message, 'Should raise error message'
  #     return
  #   end
  #   assert false, "Should raise error #{error}"
  # end
  def assert_error_message(message, record, *columns)
    raise 'must pass at least one argument' unless columns.length > 0
    raise 'must all be single objects or symbols' unless columns.all? { |c| c.is_a?(Symbol) || (c.is_a?(Hash) && c.length === 1) }
    columns.each do |c|
      sym, num = c.is_a?(Symbol) ? [c, 0] : [c.keys[0], c.values[0]]
      assert_equal message, record.errors[sym][num], "Should have the correct error message #{sym}: #{record.errors.messages}"
    end
  end
  def assert_number_of_errors(num, record)
    assert_equal num, record.errors.messages.length, "Should have #{num} error messages. Errors #{record.errors.messages}"
  end

  def assert_response_error(error_message, *keys)
    assert parse_response.key?('errors'), 'should be nested in errors'
    errors = parsed_response['errors']
    keys.each do |c|
      key, num = c.is_a?(String) ? [c, 0] : [c.keys[0], c.values[0]]
      assert_match error_message, errors[key][num], "Should have the correct error message #{key}: #{errors[key][num]}"
    end
  end
end
