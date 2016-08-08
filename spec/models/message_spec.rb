require 'rails_helper'

RSpec.describe Message, :type => :model do
  #pending "add some examples to (or delete) #{__FILE__}"
  
  # Rails.logger.debug('step1')

  before :all do
    FactoryGirl.reload
    created_messages = create_list(:message, 20)
  end  
  
  it "isn't blank uid" do
    message = Message.new
    message.uid = nil
    message.valid?
    Rails.logger.debug(message.errors)
    expect(message.errors[:uid]).to include(I18n.t('errors.messages.blank'))
  end
  
  it "is wrong_length 20 uid" do
    message = Message.new
    message.uid = '1' * 21
    message.valid?
    expect(message.errors[:uid]).to include(I18n.t('errors.messages.wrong_length', :count => 20))
  end
  
  it "isn't alphanumeric half size uid" do
    message = Message.new
    message.uid = '1234567890123456789０'
    message.valid?
    expect(message.errors[:uid]).to include(I18n.t('errors.messages.only_half_alphanumeric'))
  end
  
  it "is blank input_text" do
    message = Message.new
    message.input_text = nil
    message.valid?
    expect(message.errors[:input_text]).to include(I18n.t('errors.messages.blank'))
  end

  it "is too_long 200 input_text" do
    message = Message.new
    message.input_text = '1' * 201
    message.valid?
    expect(message.errors[:input_text]).to include(I18n.t('errors.messages.too_long', :count => 200))
  end

  it "is blank res_text" do
    message = Message.new
    message.res_text = nil
    message.valid?
    expect(message.errors[:res_text]).to include(I18n.t('errors.messages.blank'))    
  end

  it "is too_long 1000 res_text" do
    message = Message.new
    message.res_text = '1' * 1001
    message.valid?
    expect(message.errors[:res_text]).to include(I18n.t('errors.messages.too_long', :count => 1000))
  end

end