const fs = require('fs')
const path = require('path')

const htmlDir = 'html';
const puppeteer = require('puppeteer');

const takeScreenshots = async (files) => {
  const browser = await puppeteer.launch()
  const page = await browser.newPage()
  await page.setViewport({ width: 1300, height: 1300 })
  for (const {name, path} of files) {
    const shotPath = `user-pngs/${name}.png`
    console.log(`${path} => ${shotPath}`)
    await page.goto('file://' + __dirname + '/../' + path)
    await page.screenshot({path: shotPath})
  }
  await browser.close()
}

(async () => {
  try {
    const visualizationRe = /timeline-([^.]+).html/
    const files = await fs.promises.readdir(htmlDir)
    const htmlFiles = files
      .filter(name  => visualizationRe.test(name))
      .map(name => ({
        name: name.replace(visualizationRe, '$1'),
        path: path.join(htmlDir, name)
      }))

    await takeScreenshots(htmlFiles)
  } catch (e) {
    console.error('Error: ', e)
  }
})()



