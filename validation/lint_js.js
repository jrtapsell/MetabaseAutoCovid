const { getAll } = require('./common')
const standard = require('standard')
const { promisify } = require('util')

async function main () {
  const files = await getAll('.js')

  standard.asyncFiles = promisify(standard.lintFiles)
  const linted = await standard.asyncFiles(files)

  for (const file of linted.results) {
    const { filePath, messages } = file
    for (const record of messages) {
      const { line, message } = record
      console.log(filePath, line, message)
    }
  }
}

main()
  .then(e => {
    console.error(e)
    process.exit(1)
  })
