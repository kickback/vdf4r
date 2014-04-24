require 'spec_helper'

require 'vdf4r'
require 'stringio'

module VDF4R
  describe Parser do
    subject { VDF4R::Parser }

    describe 'instantiation' do
      shared_examples_for "doesn't raise" do
        it 'does not raise' do
          expect {
            subject.new(input)
          }.not_to raise_error
        end
      end

      context 'with string' do
        let(:input) { 'foo\nbar\n'}
        it_behaves_like "doesn't raise"
      end

      context 'with io' do
        let(:input) { StringIO.new('input') }
        it_behaves_like "doesn't raise"
      end

      context 'quacks right' do
        let(:input) do
          quacker = Class.new do
            def lines
              ['line 1', 'line 2']
            end
          end
          quacker.new
        end

        it_behaves_like "doesn't raise"        
      end

      context 'with inappropriate input' do
        let(:input) { 1234 }

        it 'raises' do
          expect {
            subject.new(input)
          }.to raise_error
        end
      end
    end

    describe 'items.txt fixture translation output' do
      let(:result) do
        with_fixture('items') do |fixture|
          subject.new(fixture).parse
        end
      end

      it 'quacks like hash' do
        expect(result).to respond_to(:keys)
      end

      it 'has the correct root' do
        expect(result.keys.length).to eq(1)
        expect(result.keys).to include('DOTAAbilities')
      end

      it 'has a sampling of correct top-level child entries' do
        abilities = result['DOTAAbilities']
        expect(abilities).to include('item_blink')
        expect(abilities).to include('item_blades_of_attack')
        expect(abilities).to include('item_broadsword')
        expect(abilities).to include('item_black_king_bar')
      end
    end

    describe 'bad input' do
      context 'unbalanced nesting (insufficient exit)' do
        it 'raises TranslationError' do
          expect {
            with_fixture('bad/insufficient_exit') do |fixture|
              subject.new(fixture).parse
            end
          }.to raise_error /insufficient exit/
        end
      end

      context 'unbalanced nesting (excessive exit)' do
        it 'raises TranslationError' do
          expect {
            with_fixture('bad/excessive_exit') do |fixture|
              subject.new(fixture).parse
            end
          }.to raise_error /excessive exit/
        end
      end
 
      context 'ungrammatical content' do
        it 'raises TranslationError' do
          expect {
            with_fixture('bad/ungrammatical_content') do |fixture|
              subject.new(fixture).parse
            end
          }.to raise_error /ungrammatical content/
        end
      end

      context 'too recursive' do
        it 'raises TranslationError' do
          expect {
            with_fixture('bad/too_recursive') do |fixture|
              subject.new(fixture).parse
            end
          }.to raise_error /too recursive/
        end
      end

      context 'no preceding key' do
        it 'raises TranslationError' do
          expect {
            with_fixture('bad/no_preceding_key') do |fixture|
              subject.new(fixture).parse
            end
          }.to raise_error /no preceding key/
        end
      end
    end
  end
end