# Checks that the same query is generated for both the static and dynamic syntaxes
# parameters:
# => klass - optional (defaults to Post), the test klass to be tested
# => options - optional (defaults to empty hash), the search options provided
# => query - required, the hash syntax query
# => expected_block - required, the sunspot DSL syntax query
RSpec.shared_examples_for 'a translated query' do
  let(:klass) { Post }
  let(:options) { Hash.new }
  let!(:expected) { klass.search(options, &expected_block).query.to_params }

  subject { klass.awesome_search(query, options).query.to_params }

  it 'should translate correctly' do
    # ap subject
    # ap expected
    expect(subject).to eq expected
  end
end
