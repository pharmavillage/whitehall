require "test_helper"

class AttachmentValidatorTest < ActiveSupport::TestCase
  setup do
    @validator = AttachmentValidator.new(attributes: {})
  end

  def assert_error_message(expectation, errors)
    assert errors.any? { |message| message =~ expectation },
           "expected error messages to contain #{expectation}"
  end

  test "command papers cannot have a number whilst marked as unnumbered" do
    attachment = build(:file_attachment, command_paper_number: "1234", unnumbered_command_paper: true)
    @validator.validate(attachment)
    assert_error_message %r[^cannot be set on an unnumbered paper], attachment.errors[:command_paper_number]
  end

  test "must provide house of commons paper number if parliamentary session set" do
    attachment = build(:file_attachment, parliamentary_session: "2013-14")
    @validator.validate(attachment)
    assert_error_message %r[^is required when], attachment.errors[:hoc_paper_number]
  end

  test "must provide parliamentary session if house of commons number set" do
    attachment = build(:file_attachment, hoc_paper_number: "1234")
    @validator.validate(attachment)
    assert_error_message %r[^is required when], attachment.errors[:parliamentary_session]
  end

  test "house of commons paper numbers starting with non-numeric characters are invalid" do
    attachment = build(:file_attachment, hoc_paper_number: "abcd")
    @validator.validate(attachment)
    assert_error_message %r[^must start with a number], attachment.errors[:hoc_paper_number]
  end

  test "house of commons paper numbers starting with an integer are valid" do
    %w(1 12 1234-i).each do |valid_hoc_number|
      attachment = build(:file_attachment, hoc_paper_number: valid_hoc_number)
      @validator.validate(attachment)
      assert attachment.errors[:hoc_paper_number].empty?, "Expected no error with house of commons number: '#{valid_hoc_number}'"
    end
  end

  test "house of commons papers cannot have a number while unnumbered" do
    attachment = build(:file_attachment, hoc_paper_number: "1234", unnumbered_hoc_paper: true)
    @validator.validate(attachment)
    assert_error_message %r[^cannot be set on an unnumbered paper], attachment.errors[:hoc_paper_number]
  end

  test "house of commons papers cannot have a parliamentary session while unnumbered" do
    attachment = build(:file_attachment, parliamentary_session: "2010-11", unnumbered_hoc_paper: true)
    @validator.validate(attachment)
    assert_error_message %r[^cannot be set on an unnumbered paper], attachment.errors[:parliamentary_session]
  end

  test 'unnumbered papers cannot be both "command" and "house of commons" at the same time' do
    attachment = build(:file_attachment, unnumbered_command_paper: true, unnumbered_hoc_paper: true)
    @validator.validate(attachment)
    assert_error_message %r[^cannot be set on an unnumbered Command Paper], attachment.errors[:unnumbered_hoc_paper]

    attachment = build(:file_attachment, unnumbered_command_paper: true, hoc_paper_number: "1234", parliamentary_session: "2010-11")
    @validator.validate(attachment)
    assert_error_message %r[^cannot be set on a Command Paper], attachment.errors[:hoc_paper_number]
    assert_error_message %r[^cannot be set on a Command Paper], attachment.errors[:parliamentary_session]

    attachment = build(:file_attachment, unnumbered_hoc_paper: true, command_paper_number: "1234")
    @validator.validate(attachment)
    assert_error_message %r[^cannot be set on a House of Commons paper], attachment.errors[:command_paper_number]
  end

  ["C.", "Cd.", "Cmd.", "Cmnd.", "Cm.", "CP"].each do |prefix|
    test "should be valid when the Command paper number starts with '#{prefix}'" do
      attachment = build(:file_attachment, command_paper_number: "#{prefix} 1234")
      @validator.validate(attachment)
      assert attachment.errors[:command_paper_number].empty?
    end
  end

  ["NA", "C", "Cd ", "CM.", "CP."].each do |prefix|
    test "should be invalid when the command paper number starts with '#{prefix}'" do
      attachment = build(:file_attachment, command_paper_number: "#{prefix} 1234")
      @validator.validate(attachment)
      expected_message = "is invalid. The number must start with one of #{Attachment::VALID_COMMAND_PAPER_NUMBER_PREFIXES.join(', ')}, followed by a space. If a suffix is provided, it must be a Roman numeral. Example: CP 521-IV"
      assert attachment.errors[:command_paper_number].include?(expected_message)
    end
  end

  ["-I", "-IV", "-VIII"].each do |suffix|
    test "should be valid when the command paper number ends with '#{suffix}'" do
      attachment = build(:file_attachment, command_paper_number: "C. 1234#{suffix}")
      @validator.validate(attachment)
      assert attachment.errors[:command_paper_number].empty?
    end
  end

  ["-i", "-Iv", "VIII"].each do |suffix|
    test "should be invalid when the command paper number ends with '#{suffix}'" do
      attachment = build(:file_attachment, command_paper_number: "C. 1234#{suffix}")
      @validator.validate(attachment)
      assert_not attachment.errors[:command_paper_number].empty?
    end
  end

  test "should be invalid when the command paper number has no space after the prefix" do
    attachment = build(:file_attachment, command_paper_number: "C.1234")
    @validator.validate(attachment)
    assert_not attachment.errors[:command_paper_number].empty?
  end
end
