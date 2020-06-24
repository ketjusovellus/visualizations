# Visualisointien tekeminen tietokannoista

1. Datojen päivitys valmiisiin html-tiedostoihin: `tools/data-to-js.sh html/*timelines.html`

2. Yksittäisten henkilöiden timelinejen luonti: 
 `tools/create-personal-timeline-files.sh` (kontaktidata) ja
 `tools/create-personal-manual-timeline-files.sh` (manuaaliset kirjaukset)

3. Kuvankaappaukset yksittäisten henkilöiden päivistä: `npm install puppeteer` (tarvitsee tehdä vain kerran)
   ja `node tools/screenshots.js`
=> screenshotit timelineista `user-pngs`-hakemistossa

4. Generoitujen tiedostojen poisto: `rm html/timeline-* user-pngs/*.png` 