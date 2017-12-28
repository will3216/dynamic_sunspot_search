FactoryBot.define do
  factory :author do |o|
  end

  factory :blog do |o|
  end

  factory :comment do |o|
    o.post
    o.body 'comment body'
  end

  factory :post do |o|
    o.title 'some title'
    o.body 'some body'
    o.blog
    o.author
    o.published_at -> { Time.now }
  end
end
