#!/bin/bash
#
# A script to update the data of the summary timeline visualizations
#
# run as:
# tools/data-to-js html/*timelines.html

inputContacts=data/contacts.sqlite
inputManual=data/manual-contacts.sqlite
outputContacts=data/device-data.js
outputManual=data/manual-data.js

# --- First create the device data js file ---

cat << EOF > "$outputContacts"
//--START-DEVICE-DATA
const deviceTypes = {
EOF

sqlite3 "$inputContacts" << EOF >> "$outputContacts"
.output
.separator ''
SELECT '"', device, '": "', type, '",'
FROM deviceTypes
EOF

cat << EOF >>  "$outputContacts"
}
const deviceData = [
EOF

sqlite3 "$inputContacts" << EOF >> "$outputContacts"
.output
.separator ''
SELECT '["', source, '", "', target, '", "', PRINTF('%.1fm', meanDistance), '", new Date(', startTime, '), new Date(', endTime, '), ""],'
FROM contacts
EOF

echo ']'>>  "$outputContacts"

# --- Then the manual data file ---

cat << EOF > "$outputManual"
//--START-MANUAL-DATA
const manualData = [
EOF

sqlite3 "$inputManual" << EOF >> "$outputManual"
.output
.separator ''
SELECT '["', source, '", "', target, '", "', distance, '", new Date(', startTime, '), new Date(', endTime, '), "manual"],'
FROM contacts
EOF

echo ']'>>  "$outputManual"

# Device data file ready, replace the contents in html files

for htmlFile in "$@" ; do
  csplit -sk -f 'split-start-' "$htmlFile" '/--START-DEVICE-DATA/'
  csplit -sk -f 'split-end-'   "$htmlFile" '/--END-DEVICE-DATA/'
  cat split-start-00 "$outputContacts" split-end-01 > "$htmlFile"
  rm split-*
done

# Replace also the latest manual data from manual-data.js

for htmlFile in "$@" ; do
  csplit -sk -f 'split-start-' "$htmlFile" '/--START-MANUAL-DATA/'
  csplit -sk -f 'split-end-'   "$htmlFile" '/--END-MANUAL-DATA/'
  cat split-start-00 "$outputManual" split-end-01 > "$htmlFile"
  rm split-*
done

rm "$outputContacts" "$outputManual"
