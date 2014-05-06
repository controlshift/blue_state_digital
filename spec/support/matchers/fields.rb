RSpec::Matchers.define :have_fields do |*expected_fields|

  match do |obj|
    @missing_fields = expected_fields.map do |field|
      responding = obj.respond_to?("#{field}") && obj.respond_to?("#{field}=")
      responding == true ? nil : field
    end.compact
    @missing_fields.empty?  
  end

  failure_message_for_should do |actual|
    "expected that #{actual.class} should have the field: #{@missing_fields}"
  end

  failure_message_for_should_not do |actual|
    "expected that #{actual.class} should not have the field: #{@missing_fields}"
  end

  description do
    "have the following fields: #{expected_fields}"
  end

end