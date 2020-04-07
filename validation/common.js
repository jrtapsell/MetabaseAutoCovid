const fs = require('fs').promises
const { resolve, extname, sep } = require('path')
const _ = require('lodash')

async function walk (dir, extension) {
  const dirName = dir.split(sep).pop()
  if (['node_modules', '.vscode', 'tmp'].indexOf(dirName) !== -1) {
    return []
  }
  const children = await fs.readdir(dir)
  const fileInfos = await Promise.all(
    children
      .map(p => resolve(dir, p))
      .map(
        p => fs.lstat(p).then(q => [p, q])
      ))

  const directories = fileInfos
    .filter(p => p[1].isDirectory())
    .map(p => p[0])
  const files = fileInfos
    .filter(p => !p[1].isDirectory())
    .map(p => p[0])
    .filter(p => extname(p) === extension)

  const directoryChildren = await Promise.all(directories.map(p => walk(p, extension)))
  const ret = _.concat(files, ...directoryChildren)

  return ret
}

async function getAll (extension) {
  return walk(resolve(__dirname, '..'), extension)
}

module.exports = {
  getAll
}
