describe Elasticity::Looper do

  before do
    Elasticity::Looper.any_instance.stub(:sleep)
  end

  context 'when you should wait' do

    let(:client) do
      double(:client).tap do |c|
        # Retry on the first pass through and don't retry on the second
        c.stub(:on_retry_check).and_return(true, false)
        c.stub(:on_wait)
      end
    end

    context 'and then you should not wait' do
      it 'does not communication that waiting is about to occur' do
        client.should_receive(:on_wait).once
        l = Elasticity::Looper.new(client.method(:on_retry_check), client.method(:on_wait))
        l.go
      end
    end

    context 'when no poll interval is specified' do
      it 'should poll every 60 seconds' do
        Elasticity::Looper.any_instance.should_receive(:sleep).with(60)
        l = Elasticity::Looper.new(client.method(:on_retry_check), client.method(:on_wait))
        l.go
      end
    end

    context 'when a custom poll interview is specified' do
      it 'should poll at that interval' do
        Elasticity::Looper.any_instance.should_receive(:sleep).with(999)
        l = Elasticity::Looper.new(999, client.method(:on_retry_check), client.method(:on_wait))
        l.go
      end
    end

  end

  context 'when you should not wait' do

    it 'does not communicate that waiting is about to occur' do
      client = double(:client, on_retry_check: false, on_wait: nil)
      client.should_not receive(:on_wait)
      l = Elasticity::Looper.new(client.method(:on_retry_check), client.method(:on_wait))
      l.go
    end

  end

end
