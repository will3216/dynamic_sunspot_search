# AwesomeSearch

This is an extension of the sunspot_rails gem which allows you to dynamically generate search queries with the goal of fully exposing the features of sunspot and solr via API. The following docs have been pulled straight from the sunspot docs and modified to represent the query syntax this gem provides.

## Note:
This gem does not currently support all of the features provided by sunspot, but can be expanded as needed. Simply file an issue and I'll add what you need!

See (sunspot/sunspot)[https://github.com/sunspot/sunspot] for more usage details!

## Usage
## Quickstart with Rails 3 / 4

Add to Gemfile:

```ruby
gem 'sunspot_rails'
gem 'sunspot_solr' # optional pre-packaged Solr distribution for use in development
gem 'awesome_search'
```

Bundle it!

```bash
bundle install
```

Generate a default configuration file:

```bash
rails generate sunspot_rails:install
```

If `sunspot_solr` was installed, start the packaged Solr distribution
with:

```bash
bundle exec rake sunspot:solr:start # or sunspot:solr:run to start in foreground
```

## Setting Up Objects

Add a `searchable` block to the objects you wish to index.

```ruby
class Post < ActiveRecord::Base
  include AwesomeSearch

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

    string  :sort_title do
      title.downcase.gsub(/^(an?|the)/, '')
    end
  end
end
```

`text` fields will be full-text searchable. Other fields (e.g.,
`integer` and `string`) can be used to scope queries.

## Searching Objects

```ruby
Post.awesome_search({
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
})
```

## Search In Depth

Given an object `Post` setup in earlier steps ...

### Full Text

```ruby
# All posts with a `text` field (:title, :body, or :comments) containing 'pizza'
Post.awesome_search({ fulltext: 'pizza' })

# Posts with pizza, scored higher if pizza appears in the title
Post.awesome_search({
  fulltext: {
    query: 'pizza',
    boost_fields: { title: 2.0 },
  },
})

# Posts with pizza, scored higher if featured
Post.awesome_search({
  fulltext: {
    query: 'pizza',
    boost: {
      value: 2.0,
      scope: {
        with: { featured: true },
      },
    },
  },
})

# Posts with pizza *only* in the title
Post.awesome_search({
  fulltext: {
    query: 'pizza',
    fields: synonym,
  },
})

# Posts with pizza in the title (boosted) or in the body (not boosted)
Post.awesome_search({
  fulltext: {
    query: 'pizza',
    fields: [:body, title: 2.0],
  },
})
```

#### Phrases

Solr allows searching for phrases: search terms that are close together.

In the default query parser used by Sunspot (edismax), phrase searches
are represented as a double quoted group of words.

```ruby
# Posts with the exact phrase "great pizza"
Post.awesome_search({
  fulltext: '"great pizza"',
})
```

If specified, **query_phrase_slop** sets the number of words that may
appear between the words in a phrase.

```ruby
# One word can appear between the words in the phrase, so "great big pizza"
# also matches, in addition to "great pizza"
Post.awesome_search({
  fulltext: {
    query: '"great pizza"',
    query_phrase_slop: 1,
  },
})
```

##### Phrase Boosts

Phrase boosts add boost to terms that appear in close proximity;
the terms do not *have* to appear in a phrase, but if they do, the
document will score more highly.

```ruby
# Matches documents with great and pizza, and scores documents more
# highly if the terms appear in a phrase in the title field
Post.awesome_search({
  fulltext: {
    query: 'great pizza',
    phrase_fields: {
      title: 2.0,
    },
  },
})

# Matches documents with great and pizza, and scores documents more
# highly if the terms appear in a phrase (or with one word between them)
# in the title field
Post.awesome_search({
  fulltext: {
    query: 'great pizza',
    phrase_fields: {
      title: 2.0,
    },
    phrase_slop: 1,
  },
})
```

### Scoping (Scalar Fields)

Fields not defined as `text` (e.g., `integer`, `boolean`, `time`,
etc...) can be used to scope (restrict) queries before full-text
matching is performed.

#### Positive Restrictions

```ruby
# Posts with a blog_id of 1
Post.awesome_search({
  with: {
    blog_id: 1,
  },
})

# Posts with an average rating between 3.0 and 5.0
# Note the special syntax used for ranges!
Post.awesome_search({
  with: {
    average_rating: 'range:3.0..5.0',
  },
})

# Posts with a category of 1, 3, or 5
Post.awesome_search({
  with: {
    category_ids: [1, 3, 5]
  }
})

# Posts published since a week ago
Post.awesome_search({
  with: {
    published_at: {
      greater_than: time,
    },
  },
})
```

#### Negative Restrictions

```ruby
# Posts not in category 1 or 3
Post.awesome_search({
  without: {
    category_ids: [1, 3],
  },
})

# All examples in "positive" also work negated using `without`
```

#### Empty Restrictions

```ruby
# Passing an empty array is equivalent to a no-op, meaning this...
Post.awesome_search({
  with: {
    category_ids: [],
  },
})

# ...is equivalent to this...
Post.awesome_search({})
```

#### Restrictions and Field List

```ruby
# Posts with a blog_id of 1
Post.awesome_search({
  with: {
    blog_id: 1,
  },
  field_list: [:title]
})

Post.awesome_search({
  without: {
    category_ids: [1, 3],
  },
  field_list: [:title, :author_id],
})
```

#### Disjunctions and Conjunctions

```ruby
# Posts that do not have an expired time or have not yet expired
Post.awesome_search({
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
})
```

```ruby
# Posts with blog_id 1 and author_id 2
Post.awesome_search({
  all_of: [
    {
      with: {
        blog_id: 1,
        author_id: 2,
      }
    },
  ]
})
```

```ruby
# Posts scoring with any of the two fields.
Post.awesome_search({
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
})
```

Disjunctions and conjunctions may be nested

```ruby
Post.awesome_search({
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
})
```

#### Combined with Full-Text

Scopes/restrictions can be combined with full-text searching. The
scope/restriction pares down the objects that are searched for the
full-text term.

```ruby
# Posts with blog_id 1 and 'pizza' in the title
Post.awesome_search({
  with: { blog_id: 1 },
  fulltext: 'pizza',
})
```

### Pagination

**All results from Solr are paginated**

The results array that is returned has methods mixed in that allow it to
operate seamlessly with common pagination libraries like will\_paginate
and kaminari.

By default, Sunspot requests the first 30 results from Solr.

```ruby
search = Post.awesome_search({
  fulltext: 'pizza',
})

# Imagine there are 60 *total* results (at 30 results/page, that is two pages)
results = search.results # => Array with 30 Post elements

search.total           # => 60

results.total_pages    # => 2
results.first_page?    # => true
results.last_page?     # => false
results.previous_page  # => nil
results.next_page      # => 2
results.out_of_bounds? # => false
results.offset         # => 0
```

To retrieve the next page of results, recreate the search and use the
`paginate` method.

```ruby
search = Post.awesome_search({
  fulltext: 'pizza',
  paginate: { page: 2 },
})

# Again, imagine there are 60 total results; this is the second page
results = search.results # => Array with 30 Post elements

search.total           # => 60

results.total_pages    # => 2
results.first_page?    # => false
results.last_page?     # => true
results.previous_page  # => 1
results.next_page      # => nil
results.out_of_bounds? # => false
results.offset         # => 30
```

A custom number of results per page can be specified with the
`:per_page` option to `paginate`:

```ruby
search = Post.awesome_search({
  fulltext: :pizza,
  paginate: {
    page: 1,
    per_page: 50,
  },
})
```

#### Cursor-based pagination

**Solr 4.7 and above**

With default Solr pagination it may turn that same records appear on different pages (e.g. if
many records have the same search score). Cursor-based pagination allows to avoid this.

Useful for any kinds of export, infinite scroll, etc.

Cursor for the first page is "\*".
```ruby
search = Post.awesome_search({
  fulltext: 'pizza',
  paginate: {
    cursor: '*',
  },
})

results = search.results

# Results will contain cursor for the next page
results.next_page_cursor # => "AoIIP4AAACxQcm9maWxlIDEwMTk="

# Imagine there are 60 *total* results (at 30 results/page, that is two pages)
results.current_cursor # => "*"
results.total_pages    # => 2
results.first_page?    # => true
results.last_page?     # => false
```

To retrieve the next page of results, recreate the search and use the `paginate` method with cursor from previous results.
```ruby
search = Post.awesome_search({
  fulltext: 'pizza',
  paginate: {
    cursor: 'AoIIP4AAACxQcm9maWxlIDEwMTk='
  }
})

results = search.results

# Again, imagine there are 60 total results; this is the second page
results.next_page_cursor # => "AoEsUHJvZmlsZSAxNzY5"
results.current_cursor   # => "AoIIP4AAACxQcm9maWxlIDEwMTk="
results.total_pages      # => 2
results.first_page?      # => false
# Last page will be detected only when current page contains less then per_page elements or contains nothing
results.last_page?       # => false
```

`:per_page` option is also supported.

### Faceting

Faceting is a feature of Solr that determines the number of documents
that match a given search *and* an additional criterion. This allows you
to build powerful drill-down interfaces for search.

Each facet returns zero or more rows, each of which represents a
particular criterion conjoined with the actual query being performed.
For **field facets**, each row represents a particular value for a given
field. For **query facets**, each row represents an arbitrary scope; the
facet itself is just a means of logically grouping the scopes.

By default Sunspot will only return the first 100 facet values.  You can
increase this limit, or force it to return *all* facets by setting
**limit** to **-1**.

#### Field Facets

```ruby
# Posts that match 'pizza' returning counts for each :author_id
search = Post.awesome_search({
  fulltext: 'pizza',
  facet: 'author_id',
})

search.facet(:author_id).rows.each do |facet|
  puts "Author #{facet.value} has #{facet.count} pizza posts!"
end
```

If you are searching by a specific field and you still want to see all
the options available in that field you can **exclude** it in the
faceting.

```ruby
# Posts that match 'pizza' and author with id 42
# Returning counts for each :author_id (even those not in the search result)
search = Post.awesome_search({
  fulltext: 'pizza',
  facet: {
    fields: :author_id,
    exclude: {
      with: {
        author_id: 42,
      }
    },
  },
})

search.facet(:author_id).rows.each do |facet|
  puts "Author #{facet.value} has #{facet.count} pizza posts!"
end
```

### Ordering

By default, Sunspot orders results by "score": the Solr-determined
relevancy metric. Sorting can be customized with the `order_by` method:

```ruby
# Order by average rating, descending
Post.awesome_search({
  fulltext: 'pizza',
  order_by: {
    average_rating: :desc,
  },
})

# Order by relevancy score and in the case of a tie, average rating
Post.awesome_search({
  fulltext: 'pizza',
  order_by: [
    { score: :desc },
    { average_rating: :desc },
  ],
})

# Randomized ordering
Post.awesome_search({
  fulltext: 'pizza',
  order_by: :random,
})
```

**Solr 3.1 and above**

Solr supports sorting on multiple fields using custom functions. Supported
operators and more details are available on the [Solr Wiki](http://wiki.apache.org/solr/FunctionQuery)

To sort results by a custom function use the `order_by_function` method.
Functions are defined with prefix notation:

```ruby
# Order by sum of two example fields: rating1 + rating2
Post.awesome_search({
  fulltext: 'pizza',
  order_by_function: [:sum, :rating1, :rating2, :desc],
})

# Order by nested functions: rating1 + (rating2*rating3)
Post.awesome_search({
  fulltext: 'pizza',
  order_by_function: [:sum, :rating1, [:product, :rating2, :rating3], :desc]
})

# Order by fields and constants: rating1 + (rating2 * 5)
Post.awesome_search({
  fulltext: 'pizza',
  order_by_function: [:sum, :rating1, [:product, :rating2, '5'], :desc],
})

# Order by average of three fields: (rating1 + rating2 + rating3) / 3
Post.awesome_search({
  fulltext: 'pizza',
  order_by_function: [:div, [:sum, :rating1, :rating2, :rating3], '3', :desc],
})
```

### Geospatial

**Sunspot 2.0 only**

Sunspot 2.0 supports geospatial features of Solr 3.1 and above.

Geospatial features require a field defined with `latlon`:

```ruby
class Post < ActiveRecord::Base
  searchable do
    # ...
    latlon(:location) { Sunspot::Util::Coordinates.new(lat, lon) }
  end
end
```

#### Filter By Radius

```ruby
# Searches posts within 100 kilometers of (32, -68)
Post.search do
  with(:location).in_radius(32, -68, 100)
end
```

#### Filter By Radius (inexact with bbox)

```ruby
# Searches posts within 100 kilometers of (32, -68) with `bbox`. This is
# an approximation so searches run quicker, but it may include other
# points that are slightly outside of the required distance
Post.search do
  with(:location).in_radius(32, -68, 100, :bbox => true)
end
```

#### Filter By Bounding Box

```ruby
# Searches posts within the bounding box defined by the corners (45,
# -94) to (46, -93)
Post.search do
  with(:location).in_bounding_box([45, -94], [46, -93])
end
```

#### TODO:
Support for the following needs to be added:
* Query Facets
* Range Facets
* Grouping - All features
* Sort By Distance
* Joins - Mainly just the docs
* Highlighting
* Stats
* Functions
* Spellcheck
* Add remaining documentation of other features already provided by Sunspot
