FactoryGirl.define do
  factory :message do
    sequence(:uid) { |n| format("%020d", "#{n}") }
    input_text "hello"
    res_text "hello"
    res_status "success"
  end
end