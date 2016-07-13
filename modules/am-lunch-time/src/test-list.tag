<test-list>
  <span>{successSum}/{executeSum}</span>
  <a onclick={toRouteHash} href="#">base</a>
  <div each={testCase, i in opts.testCases}>
    <a onclick={router} href={testCase.pageLink} class="step {bold: !testCase.depth}" style="margin-left: {testCase.depth * 8}px;">
      <span class="bold {success: testCase.success, error: testCase.error}" if={testCase.success||testCase.error}>
        {testCase.success ? "〇" : testCase.error ? "×" : ""}
      </span>
      {testCase.key}:
    </a>
    <a onclick={router} if={testCase.value} href={testCase.value} data-case-num={i}>{testCase.value}</a>
  </div>
  <test-iframe if={onExecute} config={config}></test-iframe>
  <style scoped>
    :scope {display: block; background-color: white;}
    :scope * {font-size: 14px;}
    a { color: blue; text-decoration: none; display: inline-block; }
    a:hover { opacity: 0.4;}
    .success { color: blue; }
    .error { color: red; }
    .bold { font-weight: bold; }
    .step { color: #333; margin-right: 10px; }
  </style>
  <script type="coffee">
    @Model = require("./Model").prototype
    @onExecute = false
    #from ./dev.coffee
    @config =
      extFile: null
      Test: class ListTest extends require("am-lunch-time/browser/Test")
    #init Model
    @Model.me = @
    @Model.iframe = @tags["test-iframe"]
    @Model.opts = opts
    #settings
    check = => @Model.check()
    #me
    @router = (e) =>
      location.href = "#" + (e.target.getAttribute("href"))
      e.preventDefault()
    @toRouteHash = (e) => location.href = "#"
    #mount
    @on("mount", check)
    riot.route("..", check)
    riot.route.start()
  </script>
</test-list>