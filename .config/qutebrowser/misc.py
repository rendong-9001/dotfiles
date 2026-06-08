c.auto_save.session = True

c.zoom.default = "125%"

c.content.proxy = 'socks5://127.0.0.1:14443'

c.content.headers.user_agent = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36'
c.content.headers.custom = {"accept":"text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7"}
c.content.headers.accept_language = "en-US,en;q=0.5"
c.qt.args = ['disable-blink-features=AutomationControlled']
