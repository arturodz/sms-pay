class UsersController < ApplicationController 
  def endpoint
    phone = params['From']
    body = params['Body']

    # Usuario deposita dinero
    if body.match('depositar')

      Compropago.api_key = "sk_test_8305a01416373e4b4"
  
      amount = /(\d+)/.match(body)[0]
      puts amount
      phone = phone.gsub('+52','')
  
      charge = Compropago::Charge.create({ product_price: amount,
                                           product_name: "Deposito a #{phone}",
                                           customer_name: "SMS Pay",
                                           customer_email: "noreply@compropago.com",
                                           payment_type: "OXXO"})
  
      Compropago::SMS.create(payment_id: charge.payment_id, customer_phone: phone, customer_company_phone: "MOVISTAR")
      
      User.update_balance amount, phone
  
      respond_to json: nil, status: 200

    # Usuario solicita su saldo 
    elsif body.match('saldo')
      user = User.where(phone: phone.gsub('+52','')).first
      client.messages.create(
        from: "+15209993914",
        to: phone.gsub('+52','+521'),
        body: "Tu saldo disponible es de: #{user.balance}"
      )

      respond_to json: nil, status: 200
    end
  end
end