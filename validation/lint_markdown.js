const report = require('vfile-reporter')
const remark = require('remark')
const fs = require('fs').promises
const { getAll } = require('./common')
const { promisify } = require('util')

async function main () {
  const files = await getAll('.md')

  console.log(files)
  const text = (await fs.readFile('../README.md')).toString()
  const rem = promisify(remark()
    .use(require('remark-preset-lint-recommended'))
    // ^ two `remark-lint` rules.
    .use({
      settings: { emphasis: '*', strong: '*' }
    // ^ `remark-stringify` settings.
    })
    .process)
  const t = await rem(text)
  console.log(report(t))
  console.log(String(t))
}

main()
  .catch(e => {
    console.error(e)
    process.exit(1)
  })
