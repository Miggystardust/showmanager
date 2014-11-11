class App
  include Mongoid::Document

  field :legal_name, type: String
  field :mailing_address, type: String
  field :phone_primary, type: String
  field :phone_alt, type: String
  field :phone_primary_has_sms, type: Mongoid::Boolean
  field :legal_accepted, type: Mongoid::Boolean

  field :created_at, :type => DateTime
  field :created_by, :type => String
  field :description, :type => String

  field :is_group, :type => Mongoid::Boolean # false if solo

  validates_presence_of :legal_name, :mailing_address, :phone_primary, :phone_primary_has_sms, :description, :message => "This field is required"

  validates_inclusion_of :legal_accepted, :in => [true], :message => "You must check this box to accept the agreement"
  
  validates_format_of :phone_primary,
        :message => "You must enter a valid telephone number",
        :with => /\A[\(\)0-9\- \+\.]{10,20} *[extension\.]{0,9} *[0-9]{0,5}\z/

  belongs_to :user
  has_one :entry
  has_one :entry_techinfo

  def is_complete?
    if self.legal_name != "" and
        self.mailing_address != "" and
        self.phone_primary != "" and
        self.legal_accepted == true
      true
    end

    false
  end

end
