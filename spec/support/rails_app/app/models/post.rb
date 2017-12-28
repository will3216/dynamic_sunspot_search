require 'sunspot'
require 'awesome_search'

class Post < ActiveRecord::Base
  include AwesomeSearch
  has_many :comments
  belongs_to :author
  belongs_to :blog

  searchable do
    text :title, :body
    text :comments do
      comments.map { |comment| comment.body }
    end

    boolean :featured
    integer :blog_id
    integer :author_id
    integer :category_ids, :multiple => true
    double  :average_rating
    time    :published_at
    time    :expired_at

    double :rating1
    double :rating2
    double :rating3

    string  :sort_title do
      title.downcase.gsub(/^(an?|the)/, '')
    end

    latlon(:location) { Sunspot::Util::Coordinates.new(lat, lon) }
  end

  def rating1; rand; end
  def rating2; rand; end
  def rating3; rand; end

  def lat
    rand*90*(rand > 0.5 ? 1 : -1 )
  end

  def lon
    rand*180*(rand > 0.5 ? 1 : -1 )
  end

  def category_ids
    [1, 2, 3, 4]
  end
end
