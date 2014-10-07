require 'spec_helper'
require 'wheelie/model'
require 'wheelie/attribute'

describe Wheelie::Model do

  subject { described_class.new('model') }

  describe '#label_attr' do
    it 'returns the model’s first attribute' do
      subject.attr('first_attr')
      subject.attr('second_attr')

      expect(subject.label_attr.name).to eql('first_attr')
    end
  end

end
