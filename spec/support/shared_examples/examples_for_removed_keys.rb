# frozen_string_literal: true

RSpec.shared_examples "available key does not exist" do
  it "contains no key with suffix :AVAILABLE" do
    expect(unique_keys).not_to include(key.available)
  end
end

RSpec.shared_examples "available key expires after 5 seconds" do
  it "contains a key with suffix :AVAILABLE" do
    expect(unique_keys).to include(key.available)
    expect(lrange(key.available, -1, 1).shift).to eq(locked_jid)
    expect(key.available).to expire_in(5)
  end
end

RSpec.shared_examples "exists key does not exist" do
  it "contains no key with suffix :EXISTS" do
    expect(unique_keys).not_to include(key.exists)

    if lock_ttl # TODO: Refactor this
      expect(get(key.exists)).to eq(locked_jid)
      expect(key.exists).to expire_in(lock_ttl)
    else
      expect(get(key.exists)).to be_nil
    end
  end
end

RSpec.shared_examples "digest does not exist in unique set" do
  it "digest is missing in unique set" do
    expect(unique_digests).not_to include(key.digest)
  end
end

RSpec.shared_examples "keys are removed by unlock" do
  it_behaves_like "available key expires after 5 seconds"
  it_behaves_like "exists key does not exist"
  it_behaves_like "digest does not exist in unique set"
end

RSpec.shared_examples "keys are removed by delete" do
  it_behaves_like "available key does not exist"
  it_behaves_like "exists key does not exist"
  it_behaves_like "digest does not exist in unique set"
end

RSpec.shared_examples "keys for other jobs are not removed" do
  it_behaves_like "available key exists"
  it_behaves_like "exists key exists"
  it_behaves_like "digest exists in unique set"
end
