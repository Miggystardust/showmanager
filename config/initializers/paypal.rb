Rails3MongoidDevise::Application.configure do
  config.after_initialize do

    #ActiveMerchant::Billing::Base.mode = :test
    # set up Paypal integration
    ::PAYPAL_KEYS = YAML.load_file("#{Rails.root}/keys/paypal.yaml")[Rails.env].symbolize_keys

    paypal_options = {      
       login: PAYPAL_KEYS[:username],
       password: PAYPAL_KEYS[:password],
       signature: PAYPAL_KEYS[:signature],
    }

    ::EXPRESS_GATEWAY = ActiveMerchant::Billing::PaypalExpressGateway.new(paypal_options)
  end
end

