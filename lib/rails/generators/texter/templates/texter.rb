<% module_namespacing do -%>
class <%= class_name %> < ActionTexter::Base
  default <%= key_value :from, '"+15551234567"' %>
<% actions.each do |action| -%>

  def <%= action %>
    @greeting = "Hi"

    sms <%= key_value :to, '"+15557654321"' %>
  end
<% end -%>
end
<% end -%>
