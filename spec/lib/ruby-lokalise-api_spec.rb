RSpec.describe Lokalise do
  specify '.client' do
    expect(test_client).to be_an_instance_of(Lokalise::Client)
    expect(test_client.token).to eq('123')
  end
end