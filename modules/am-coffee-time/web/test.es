import Test from 'am-coffee-time/browser/Test'
import AutoEvent from 'am-autoevent/browser/AutoEvent-no-gen'
import assert from 'assert'

const autoEvent = new AutoEvent()
const $ = (selector) => document.querySelector(selector)
const actions = {
  lang: (type) => {
    autoEvent.wait(200).addEvent(() => {
      $('before-login > span:first-child').innerHTML = `<div>言語は ${type} です</div>` + $('before-login > span:first-child').innerHTML
    })
  },
  動作フロー確認用: () => console.log('動作フロー確認です'),
  結果: (値) => {
    if (値.match('成功')) assert(true)
    else if (値.match('失敗')) assert(false, '失敗です')
  },
  ID入力: (value) => {
    autoEvent
      .wait(400).setValue('[name="id"]', value)
  },
  PW入力: (value) => {
    autoEvent
      .wait(400).setValue('[name="pw"]', value)
      .wait(400).click('[name="check"]')
      .wait(400).addEvent(() => assert($('after-login'), 'after-login not found'))
  }
}
autoEvent.register()
Test.start(actions)
autoEvent.start(1, () => console.info('finished'))
