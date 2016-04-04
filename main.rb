require 'mechanize'

class DegrausSchedule
  def initialize(user, pass)
    @credentials = { user: user, pass: pass }.freeze
  end

  def messages_of_the_day
    messages = []

    mechanize.get('http://degrausnet.com.br/logar.asp?erro=1') do |login_page|
      student_page = login_page.form_with(action: 'login.asp') do |f|
        f.login = credentials[:user]
        f.senha = credentials[:pass]
      end.submit

      event_page = mechanize.get('http://degrausnet.com.br/r_eventos_consulta.asp?id=3506&aln=01103-7&acao=pesquisar&data1=31/03/2016')
      # event_page = mechanize.click(student_page.link_with(text: /Histórico do Dia/))
      result = event_page.xpath('//div[contains(text(), "Mensagens do Colégio Degraus")]').first

      if result
        texts = result.children[2].children[3].children[0].children[0].children
        messages = texts.map { |e| e.text unless e.text.empty? }
      end
    end

    messages.compact
  end

  private

  attr_reader :credentials

  def mechanize
    @mechanize ||= Mechanize.new
  end
end

schedule = DegrausSchedule.new('', '')
puts schedule.messages_of_the_day
