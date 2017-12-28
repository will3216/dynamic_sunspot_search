#NOTE: https://github.com/sunspot/sunspot/tree/c4cc039583e4ecacb55bf4909ae07c9f93023c56#searching-objects
require 'rails_helper'

RSpec.describe 'basic conversion' do
  it_behaves_like 'a translated query' do
    let!(:time_now) { Time.now }
    let(:expected_block) do
      Proc.new do |search|
        search.fulltext 'best pizza'

        search.with :blog_id, 1
        search.with(:published_at).less_than time_now
        search.field_list :blog_id, :title
        search.order_by :published_at, :desc
        search.paginate page: 2, per_page: 15
        search.facet :category_ids, :author_id
      end
    end
    let(:query) do
      {
        fulltext: 'best pizza',
        with: [
          {blog_id: 1},
          {published_at: {
              less_than: time_now,
            },
          },
        ],
        field_list: [:blog_id, :title],
        order_by: {
          published_at: :desc,
        },
        paginate: {
          page: 2,
          per_page: 15,
        },
        facet: [
          :category_ids,
          :author_id,
        ]
      }
    end
  end

  it_behaves_like 'a translated query' do
    let(:expected_block) do
      Proc.new do |search|
        search.fulltext 'pizza' do
          boost_fields title: 2.0
        end
      end
    end
    let(:query) do
      {
        fulltext: {
          query: 'pizza',
          boost_fields: { title: 2.0 },
        },
      }
    end
  end

  it_behaves_like 'a translated query' do
    let(:expected_block) do
      Proc.new do |search|
        search.fulltext 'pizza' do
          boost(2.0) { with(:featured, true) }
        end
      end
    end
    let(:query) do
      {
        fulltext: {
          query: 'pizza',
          boost: {
            value: 2.0,
            scope: {
              with: { featured: true },
            },
          },
        },
      }
    end
  end

  [[:title], :title, 'title'].each do |synonym|
    it_behaves_like 'a translated query' do
      let(:expected_block) do
        Proc.new do |search|
          search.fulltext 'pizza' do
            fields(:title)
          end
        end
      end
      let(:query) do
        {
          fulltext: {
            query: 'pizza',
            fields: synonym,
          },
        }
      end
    end
  end

  it_behaves_like 'a translated query' do
    let(:expected_block) do
      Proc.new do |search|
        search.fulltext 'pizza' do
          fields(:body, title: 2.0)
        end
      end
    end
    let(:query) do
      {
        fulltext: {
          query: 'pizza',
          fields: [:body, title: 2.0],
        },
      }
    end
  end

  it_behaves_like 'a translated query' do
    let(:expected_block) do
      Proc.new do |search|
        search.fulltext '"great pizza"'
      end
    end
    let(:query) do
      {
        fulltext: '"great pizza"',
      }
    end
  end

  it_behaves_like 'a translated query' do
    let(:expected_block) do
      Proc.new do |search|
        search.fulltext '"great pizza"' do
          query_phrase_slop 1
        end
      end
    end
    let(:query) do
      {
        fulltext: {
          query: '"great pizza"',
          query_phrase_slop: 1,
        },
      }
    end
  end

  it_behaves_like 'a translated query' do
    let(:expected_block) do
      Proc.new do |search|
        search.fulltext 'great pizza' do
          phrase_fields title: 2.0
        end
      end
    end
    let(:query) do
      {
        fulltext: {
          query: 'great pizza',
          phrase_fields: {
            title: 2.0,
          },
        },
      }
    end
  end

  it_behaves_like 'a translated query' do
    let(:expected_block) do
      Proc.new do |search|
        search.fulltext 'great pizza' do
          phrase_fields title: 2.0
          phrase_slop 1
        end
      end
    end
    let(:query) do
      {
        fulltext: {
          query: 'great pizza',
          phrase_fields: {
            title: 2.0,
          },
          phrase_slop: 1,
        },
      }
    end
  end

  it_behaves_like 'a translated query' do
    let(:expected_block) do
      Proc.new do |search|
        search.with(:blog_id, 1)
      end
    end
    let(:query) do
      {
        with: {
          blog_id: 1,
        },
      }
    end
  end

  it_behaves_like 'a translated query' do
    let(:expected_block) do
      Proc.new do |search|
        search.with(:average_rating, 3.0..5.0)
      end
    end
    let(:query) do
      {
        with: {
          average_rating: 'range:3.0..5.0',
        },
      }
    end
  end

  it_behaves_like 'a translated query' do
    let(:expected_block) do
      Proc.new do |search|
        search.with(:category_ids, [1, 3, 5])
      end
    end
    let(:query) do
      {
        with: {
          category_ids: [1, 3, 5]
        }
      }
    end
  end

  it_behaves_like 'a translated query' do
    let!(:time) { 1.week.ago }
    let(:expected_block) do
      Proc.new do |search|
        search.with(:published_at).greater_than(time)
      end
    end
    let(:query) do
      {
        with: {
          published_at: {
            greater_than: time,
          },
        },
      }
    end
  end

  it_behaves_like 'a translated query' do
    let(:expected_block) do
      Proc.new do |search|
        search.without(:category_ids, [1, 3])
      end
    end
    let(:query) do
      {
        without: {
          category_ids: [1, 3],
        },
      }
    end
  end

  it_behaves_like 'a translated query' do
    let(:expected_block) do
      Proc.new do |search|
        search.with(:category_ids, [])
      end
    end
    let(:query) do
      {
        with: {
          category_ids: [],
        },
      }
    end
  end

  it_behaves_like 'a translated query' do
    let(:expected_block) do
      Proc.new do |search|
        search.with(:blog_id, 1)
        search.field_list [:title]
      end
    end
    let(:query) do
      {
        with: {
          blog_id: 1,
        },
        field_list: [:title]
      }
    end
  end

  it_behaves_like 'a translated query' do
    let(:expected_block) do
      Proc.new do |search|
        search.without(:category_ids, [1, 3])
        search.field_list [:title, :author_id]
      end
    end
    let(:query) do
      {
        without: {
          category_ids: [1, 3],
        },
        field_list: [:title, :author_id],
      }
    end
  end

  it_behaves_like 'a translated query' do
    let!(:time) { Time.now }
    let(:expected_block) do
      Proc.new do |search|
        search.any_of do
          with(:expired_at).greater_than(time)
          with(:expired_at, nil)
        end
      end
    end
    let(:query) do
      {
        any_of: {
          with: [
            {
              expired_at: {
                greater_than: time,
              },
            },
            {
              expired_at: nil,
            },
          ],
        },
      }
    end
  end

  it_behaves_like 'a translated query' do
    let(:expected_block) do
      Proc.new do |search|
        search.all_of do
          with(:blog_id, 1)
          with(:author_id, 2)
        end
      end
    end
    let(:query) do
      {
        all_of: [
          {
            with: {
              blog_id: 1,
              author_id: 2,
            }
          },
        ]
      }
    end
  end

  it_behaves_like 'a translated query' do
    let(:expected_block) do
      Proc.new do |search|
        search.any do
          fulltext 'keyword1', fields: :title
          fulltext 'keyword2', fields: :body
        end
      end
    end
    let(:query) do
      {
        any: [
          {
            fulltext: {
              query: 'keyword1',
              fields: :title,
            },
          },
          {
            fulltext: {
              query: 'keyword2',
              fields: :body,
            },
          },
        ],
      }
    end
  end

  it_behaves_like 'a translated query' do
    let(:expected_block) do
      Proc.new do |search|
        search.any_of do
          with(:blog_id, 1)
          all_of do
            with(:blog_id, 2)
            with(:category_ids, 3)
          end
        end

        search.any do
          all do
            fulltext 'keyword', fields: :title
            fulltext 'keyword', fields: :body
          end
          all do
            fulltext 'keyword', fields: :comments
            fulltext 'keyword', fields: :title
          end
          fulltext 'keyword2', fields: :body
        end
      end
    end
    let(:query) do
      {
        any_of: {
          with: { blog_id: 1},
          all_of: {
            with: {
              blog_id: 2,
              category_ids: 3,
            },
          },
        },
        any: [
          {
            all: [
              {
                fulltext: {
                  query: 'keyword',
                  fields: :title,
                },
              },
              {
                fulltext: {
                  query: 'keyword',
                  fields: :body,
                },
              },
            ],
          },
          {
            all: [
              {
                fulltext: {
                  query: 'keyword',
                  fields: :comments,
                },
              },
              {
                fulltext: {
                  query: 'keyword',
                  fields: :title,
                },
              },
            ],
          },
          {
            fulltext: {
              query: 'keyword2',
              fields: :body
            },
          },
        ],
      }
    end
  end

  it_behaves_like 'a translated query' do
    let(:expected_block) do
      Proc.new do |search|
        search.with(:blog_id, 1)
        search.fulltext('pizza')
      end
    end
    let(:query) do
      {
        with: { blog_id: 1 },
        fulltext: 'pizza',
      }
    end
  end

  it_behaves_like 'a translated query' do
    let(:expected_block) do
      Proc.new do |search|
        search.fulltext 'pizza'
      end
    end
    let(:query) do
      {
        fulltext: 'pizza',
      }
    end
  end

  it_behaves_like 'a translated query' do
    let(:expected_block) do
      Proc.new do |search|
        search.fulltext 'pizza'
        search.paginate page: 2
      end
    end
    let(:query) do
      {
        fulltext: 'pizza',
        paginate: { page: 2 },
      }
    end
  end

  it_behaves_like 'a translated query' do
    let(:expected_block) do
      Proc.new do |search|
        search.fulltext 'pizza'
        search.paginate page: 1, per_page: 50
      end
    end
    let(:query) do
      {
        fulltext: :pizza,
        paginate: {
          page: 1,
          per_page: 50,
        },
      }
    end
  end

  it_behaves_like 'a translated query' do
    let(:expected_block) do
      Proc.new do |search|
        search.fulltext 'pizza'
        search.paginate cursor: '*'
      end
    end
    let(:query) do
      {
        fulltext: 'pizza',
        paginate: {
          cursor: '*',
        },
      }
    end
  end

  # it_behaves_like 'a translated query' do
  #   let(:expected_block) do
  #     Proc.new do |search|
  #       search.fulltext 'pizza'
  #       search.paginate cursor: 'AoIIP4AAACxQcm9maWxlIDEwMTk='
  #     end
  #   end
  #   let(:query) do
  #     {
  #       fulltext: 'pizza',
  #       paginate: {
  #         cursor: 'AoIIP4AAACxQcm9maWxlIDEwMTk='
  #       }
  #     }
  #   end
  # end

  it_behaves_like 'a translated query' do
    let(:expected_block) do
      Proc.new do |search|
        search.fulltext 'pizza'
        search.facet :author_id
      end
    end
    let(:query) do
      {
        fulltext: 'pizza',
        facet: 'author_id',
      }
    end
  end

  it_behaves_like 'a translated query' do
    let(:expected_block) do
      Proc.new do |search|
        search.fulltext 'pizza'
        author_filter = search.with(:author_id, 42)
        search.facet :author_id, exclude: [author_filter]
      end
    end
    let(:query) do
      {
        fulltext: 'pizza',
        facet: {
          fields: :author_id,
          exclude: {
            with: {
              author_id: 42,
            }
          },
        },
      }
    end
  end

  it_behaves_like 'a translated query' do
    let(:expected_block) do
      Proc.new do |search|
        search.fulltext("pizza")
        search.order_by(:average_rating, :desc)
      end
    end
    let(:query) do
      {
        fulltext: 'pizza',
        order_by: {
          average_rating: :desc,
        },
      }
    end
  end

  it_behaves_like 'a translated query' do
    let(:expected_block) do
      Proc.new do |search|
        search.fulltext('pizza')

        search.order_by(:score, :desc)
        search.order_by(:average_rating, :desc)
      end
    end
    let(:query) do
      {
        fulltext: 'pizza',
        order_by: [
          { score: :desc },
          { average_rating: :desc },
        ],
      }
    end
  end

  # Won't match because the seed used is different between queries
  # it_behaves_like 'a translated query' do
  #   let(:expected_block) do
  #     Proc.new do |search|
  #       search.fulltext("pizza")
  #       search.order_by(:random)
  #     end
  #   end
  #   let(:query) do
  #     {
  #       fulltext: 'pizza',
  #       order_by: :random,
  #     }
  #   end
  # end

  it_behaves_like 'a translated query' do
    let(:expected_block) do
      Proc.new do |search|
        search.fulltext("pizza")
        search.order_by_function(:sum, :rating1, :rating2, :desc)
      end
    end
    let(:query) do
      {
        fulltext: 'pizza',
        order_by_function: [:sum, :rating1, :rating2, :desc],
      }
    end
  end

  it_behaves_like 'a translated query' do
    let(:expected_block) do
      Proc.new do |search|
        search.fulltext("pizza")
        search.order_by_function(:sum, :rating1, [:product, :rating2, :rating3], :desc)
      end
    end
    let(:query) do
      {
        fulltext: 'pizza',
        order_by_function: [:sum, :rating1, [:product, :rating2, :rating3], :desc]
      }
    end
  end

  it_behaves_like 'a translated query' do
    let(:expected_block) do
      Proc.new do |search|
        search.fulltext("pizza")
        search.order_by_function(:sum, :rating1, [:product, :rating2, '5'], :desc)
      end
    end
    let(:query) do
      {
        fulltext: 'pizza',
        order_by_function: [:sum, :rating1, [:product, :rating2, '5'], :desc],
      }
    end
  end

  it_behaves_like 'a translated query' do
    let(:expected_block) do
      Proc.new do |search|
        search.fulltext("pizza")
        search.order_by_function(:div, [:sum, :rating1, :rating2, :rating3], '3', :desc)
      end
    end
    let(:query) do
      {
        fulltext: 'pizza',
        order_by_function: [:div, [:sum, :rating1, :rating2, :rating3], '3', :desc],
      }
    end
  end

  it_behaves_like 'a translated query' do
    let(:expected_block) do
      Proc.new do |search|
        search.with(:location).in_radius(32, -68, 100)
      end
    end
    let(:query) do
      {
        with: {
          location: {
            in_radius: [32, -68, 100],
          },
        },
      }
    end
  end

  it_behaves_like 'a translated query' do
    let(:expected_block) do
      Proc.new do |search|
        search.with(:location).in_radius(32, -68, 100, bbox: true)
      end
    end
    let(:query) do
      {
        with: {
          location: {
            in_radius: [32, -68, 100, bbox: true],
          },
        },
      }
    end
  end

  it_behaves_like 'a translated query' do
    let(:expected_block) do
      Proc.new do |search|
        search.with(:location).in_bounding_box([45, -94], [46, -93])
      end
    end
    let(:query) do
      {
        with: {
          location: {
            in_bounding_box: [[45, -94], [46, -93]],
          },
        },
      }
    end
  end
end
