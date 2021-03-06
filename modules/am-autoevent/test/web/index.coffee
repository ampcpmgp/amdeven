$ = require("jquery")
AutoEvent = require("am-autoevent")
AutoEventNoGen = require("am-autoevent/browser/AutoEvent-no-gen")

do => #setup
  $("button").click( =>
    console.log 2
    )
  $("select").on("change", (e) =>
    console.log e.currentTarget.value
  )
func = (Klass) =>
  ae = new Klass()
  ae.register()
    .click("#test").click("#test")
    .wait(500).click("#test").setValue("#input",Date.now())
    .wait(200).click("#test2").setValue("#input2",Date.now())
    .wait("300").addEvent(=> console.log("hello"))
    .waitSelector("#test").setHtml("#test", Date.now())
    .start(2, =>
      console.info "finished"
    )

require("am-coffee-time/browser/Test").start(
  test:  =>
    func(AutoEvent)
    $ERROR_IS_OKAY
  testNoGen:  =>
    func(AutoEventNoGen)
  timeout: (ms) =>
    AutoEvent = AutoEvent::
    AutoEvent.timeoutMsec = parseInt(ms)
    AutoEvent.register().waitSelector("box").start()
    createTimeoutBox = =>
      $("body").append("<box>box</box>")
    setTimeout(createTimeoutBox, 500)
  clickAssert: (assertFlg) =>
    ae = new AutoEvent
    ae.register().wait(300).click(".box555", assertFlg is true).start()
  select: (value) =>
    ae = new AutoEvent
    ae.register().wait(300).selectValue("select", value).start()
  scroll: =>
    scrollTest2.scrollTop = 30
    console.info "finished"
)
