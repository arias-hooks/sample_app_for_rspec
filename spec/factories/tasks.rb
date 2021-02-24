FactoryBot.define do
  factory :task do
    title { 'Task' }
    status { :todo }
    association :user
  end
end
