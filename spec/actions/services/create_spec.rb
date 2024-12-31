require 'rails_helper'

RSpec.describe Services::Create, type: :action do
  describe '.call' do
    let(:service) { instance_double('Service') }
    let(:params) { { service: { cron_schedule: { schedule: '0 0 * * *' } } } }

    before do
      allow(Services::CreateAssociations).to receive(:execute)
      allow(Services::Save).to receive(:execute)
    end

    context 'when called with valid params' do
      it 'calls Services::CreateAssociations' do
        described_class.call(service, params)
        expect(Services::CreateAssociations).to have_received(:execute).with(hash_including(service: service, params: params))
      end

      it 'calls Services::Save' do
        described_class.call(service, params)
        expect(Services::Save).to have_received(:execute).with(hash_including(service: service, params: params))
      end
    end

    context 'when there is an exception during execution' do
      before do
        allow(Services::CreateAssociations).to receive(:execute).and_raise(StandardError.new('Something went wrong'))
      end

      it 'raises an error' do
        expect { described_class.call(service, params) }.to raise_error(StandardError, 'Something went wrong')
      end
    end

    context 'when cron_schedule is not present in params' do
      let(:params) { { service: {} } }

      it 'still calls Services::CreateAssociations' do
        described_class.call(service, params)
        expect(Services::CreateAssociations).to have_received(:execute).with(hash_including(service: service, params: params))
      end

      it 'still calls Services::Save' do
        described_class.call(service, params)
        expect(Services::Save).to have_received(:execute).with(hash_including(service: service, params: params))
      end
    end
  end
end