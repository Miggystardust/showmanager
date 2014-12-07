class App
  include Mongoid::Document

  field :legal_name, type: String
  field :mailing_address, type: String
  field :phone_primary, type: String
  field :phone_alt, type: String
  field :phone_primary_has_sms, type: Mongoid::Boolean
  field :legal_accepted, type: Mongoid::Boolean

  field :created_at, :type => DateTime
  field :updated_at, type: DateTime

  field :created_by, :type => String
  field :description, :type => String

  # paypal integration
  field :purchase_ip, :type => String
  field :purchased_at, :type => DateTime
  field :express_token, :type => String
  field :express_payer_id, :type => String
  field :purchase_price, :type => Float  # this is in cents!! Not dollars! 

  field :is_group, :type => Mongoid::Boolean # false if solo

  # upon submit, we lock the app.
  field :locked, :type => Mongoid::Boolean

  validates_presence_of :legal_name, :mailing_address, :phone_primary, :phone_primary_has_sms, :description, :message => "This field is required"

  validates_inclusion_of :legal_accepted, :in => [true], :message => "You must check this box to accept the agreement"
  
  validates_format_of :phone_primary,
        :message => "You must enter a valid telephone number",
        :with => /\A[\(\)0-9\- \+\.]{10,20} *[extension\.]{0,9} *[0-9]{0,5}\z/

  belongs_to :user
  embeds_one :entry, autobuild: true
  embeds_one :entry_techinfo, autobuild: true

  has_one :entry
  has_one :entry_techinfo

  def is_complete?
    # true if the initial part of the application is complete
    if self.legal_name.present? and
        self.mailing_address.present? and
        self.phone_primary.present? and
        self.legal_accepted == true
     return true
    end

    false
  end

  def purchase
    response = EXPRESS_GATEWAY.purchase(self.purchase_price, express_purchase_options)
    self.update_attribute(:purchased_at, Time.now) if response.success?
    response.success?
  end

  def express_token=(token)
    self[:express_token] = token
    if new_record? && !token.blank?
      # you can dump details var if you need more info from buyer
      details = EXPRESS_GATEWAY.details_for(token)
      self.express_payer_id = details.payer_id
    end
  end

  # calculate the purchase price for this app based on the current time
  def get_current_price
    #  Safety: We'll never charge less than $29.00. I'd set this to zero, but um, no.
    rate = 2900

    BHOF_RATES.each { |bh|
      if Time.now() >= bh[:deadline]
        rate = bh[:rate]
      end
    }
    rate
  end

  def complete?
    # true if the application and it's subcomponents are complete
    if self.entry and self.entry_techinfo and self.is_complete? and self.entry.is_complete? and self.entry_techinfo.is_complete? and self.purchased_at.present? 
      true
    else
      false
    end
  end 


  private

  def express_purchase_options
    {
      :ip => purchase_ip,
      :token => express_token,
      :payer_id => express_payer_id
    }
  end

end
