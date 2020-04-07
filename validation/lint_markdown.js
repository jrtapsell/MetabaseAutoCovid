const report = require('vfile-reporter')
const remark = require('remark')
const emphasisMarker = require('remark-lint-emphasis-marker')
const strongMarker = require('remark-lint-strong-marker')
const fs = require('fs').promises

async function main () {
  const text = (await fs.readFile('../README.md')).toString()
  remark()
    .use(emphasisMarker, '*')
    .use(strongMarker, '*')
    // ^ two `remark-lint` rules.
    .use({
      settings: { emphasis: '*', strong: '*' }
    // ^ `remark-stringify` settings.
    })
    .process(text, function (err, file) {
      console.error(report(err || file))
      console.log(String(file))
    })
}

main()
  .catch(e => {
    console.error(e)
    process.exit(1)
  })
