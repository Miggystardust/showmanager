class App
  include Mongoid::Document
  field :legal_name, type: String
  field :mailing_address, type: String
  field :phone_primary, type: String
  field :phone_alt, type: String
  field :phone_primary_has_sms, type: Mongoid::Boolean
  field :legal_accepted, type: Mongoid::Boolean
  
  validates_presence_of :legal_name, :mailing_address, :phone_primary, :phone_primary_has_sms
  
  validates_format_of :phone_primary,
        :message => "must be a valid telephone number.",
        :with => /\A[\(\)0-9\- \+\.]{10,20} *[extension\.]{0,9} *[0-9]{0,5}\z/
  
end
