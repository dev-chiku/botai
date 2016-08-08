class Message < ActiveRecord::Base
  validates :uid,
    presence: true,
    length: { is: 20 },
    format: { with: /\A[a-z0-9]+\z/i, message: I18n.t('errors.messages.only_half_alphanumeric') }
    
  validates :input_text, 
    presence: true, 
    length: { maximum: 200 }
    
  validates :res_text, 
    presence: true, 
    length: { maximum: 1000 }
    
  def space_input_text?
    input_text == /^[ ]+$/
  end
end