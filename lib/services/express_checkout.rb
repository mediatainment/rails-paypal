class RailsPaypalGem::ExpressCheckout < RailsPaypalGem
  attr_accessor :params
  attr_accessor :token
  attr_accessor :line_items

  def initialize(line_items, currency = 'EUR')
    self.line_items = line_items
    self.params = {}
    total = 0.0
    line_items.each_with_index do |li, i|
      self.params["L_PAYMENTREQUEST_0_NAME#{i}"] = li[:name] if li.has_key?(:name)
      self.params["L_PAYMENTREQUEST_0_QTY#{i}"] = li[:quantity] if li.has_key?(:quantity)
      self.params["L_PAYMENTREQUEST_0_AMT#{i}"] = li[:price]
      self.params["L_PAYMENTREQUEST_0_DESC#{i}"] = li[:description] if li.has_key?(:description)
      total += (li[:price].to_f * li[:quantity].to_i)
    end
    params["PAYMENTREQUEST_0_AMT"] = total.to_s
    params["PAYMENTREQUEST_0_CURRENCYCODE"] = currency

  end

  def set(action = 'Sale', currency = 'EUR')
    self.params["PAYMENTREQUEST_0_CURRENCYCODE"] = currency
    self.params["PAYMENTREQUEST_0_PAYMENTACTION"] = action
    self.params["METHOD"] = 'SetExpressCheckout'
    response = self.class.call(self.params)
    if response["ACK"] == 'Success'
      self.token = response["TOKEN"]
    else
      raise response["L_ERRORCODE0"]+":"+response["L_LONGMESSAGE0"]
    end
  end

  def get
    set if self.token.nil?
    self.class.get(self.token)
  end

  def redirect_url
    set if self.token.nil?
    if Rails.env == "development" || Rails.env == "staging"
      "https://www.sandbox.paypal.com/webscr?cmd=_express-checkout&token=" + self.token
    elsif Rails.env == "production"
      "https://www.paypal.com/webscr?cmd=_express-checkout&token=" + self.token
    end
  end

  def self.get(token)
    call({"TOKEN" => token, "METHOD" => "GetExpressCheckoutDetails"})
  end

  def self.do(token, payer_id, amount, currency="EUR")
    ret = call({
                   "TOKEN" => token,
                   "PAYERID" => payer_id,
                   "AMT" => amount,
                   "PAYMENTACTION" => 'Sale',
                   "METHOD" => "DoExpressCheckoutPayment",
                   "CURRENCYCODE" => currency})
    if ret["PAYMENTSTATUS"] == 'Completed'
      ret["TRANSACTIONID"]
    else
      puts "#{ret.inspect}"
    end
  end

end
