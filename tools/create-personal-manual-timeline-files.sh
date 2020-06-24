#!/bin/bash
#
# A script for making simple visualizations of the contact data
# Each device gets its own visualization file per day
#
# Use like:
# tools/create-personal-manual-timeline-files.sh

db=data/manual-contacts.sqlite
dayMs=86400000
may18_2020_ms=1589749200000 # 2020-05-18 00:00 EET

millisToDate () {
  perl -e "use POSIX qw( strftime ); print strftime('%Y-%m-%d', localtime($1 / 1000));"
}

for (( d=0; d<21; d++ )); do
  startTimeMs=$((may18_2020_ms + d*dayMs))
  endTimeMs=$((startTimeMs + dayMs))

  echo "On $(millisToDate "$startTimeMs")"
  devices=( `sqlite3 ${db} << EOF
.output
.separator ''
SELECT DISTINCT source FROM contacts WHERE startTime BETWEEN $startTimeMs AND $endTimeMs ORDER BY source
EOF` )

  for device in "${devices[@]}"; do
    output=html/timeline-${device}-$(millisToDate "$startTimeMs")-manual.html
    echo "$output"
    cat << EOF > "${output}"
<html lang="en">
  <head title="Visualization: ${device} manual">
    <meta charset="utf-8"/>
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"
      integrity="sha256-4+XzXVhsDmqanXGHaHvgh1gMQKX40OUvDEBTu8JcmNs="
      crossorigin="anonymous">
    </script>
    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
    <script type="text/javascript">
      google.charts.load('current', {'packages':['timeline']})
      google.charts.setOnLoadCallback(drawCharts)
      const data = [
EOF

    sqlite3 "$db" << EOF | sort -f >> "$output"
.output
.separator ''
SELECT '["', source, '", "', target, '", "', distance, '", new Date(', startTime, '), new Date(', endTime, '), ""],'
FROM contacts
WHERE source='${device}' AND startTime BETWEEN $startTimeMs AND $endTimeMs
EOF

    cat << EOF >> "${output}"
      ]
      function drawCharts() {
        const dataTable = new google.visualization.DataTable()
        dataTable.addColumn({ type: 'string', id: 'Origin' })
        dataTable.addColumn({ type: 'string', id: 'Device' })
        dataTable.addColumn({ type: 'string', id: 'Distance' })
        dataTable.addColumn({ type: 'date', id: 'Start' })
        dataTable.addColumn({ type: 'date', id: 'End' })
        dataTable.addColumn({ type: 'string', id: 'Type' })
        dataTable.addRows(data)

        const origins = dataTable.getDistinctValues(0).sort()
        origins.forEach(id => {
          const dataView = new google.visualization.DataView(dataTable)
          dataView.setColumns([1,2,3,4])
          dataView.setRows(dataTable.getFilteredRows([{ column: 0, value: id}]))
          drawChart(id, dataView)
        })
      }

      function drawChart(id, view) {
        if (view.getViewRows().length === 0) return

        const container = document.getElementById('timeline-'+id)
        const chart = new google.visualization.Timeline(container)

        chart.draw(view, {
          timeline: { colorByRowLabel: true },
          hAxis: {
            format: 'HH:mm',
            minValue: new Date(${startTimeMs}),
            maxValue: new Date(${endTimeMs})
          }
        })
        const fmtFI = new Intl.DateTimeFormat('fi', { year: 'numeric', month: 'numeric', day: 'numeric' })
        \$('#${device} h1').append(' ' + fmtFI.format(new Date(${startTimeMs})))
      }
    </script>
    <style>
      h1 { font-family: Arial, sans-serif; font-size: 15px; margin: 10px 8px; font-weight: bold }
      .timeline { height: 100%; }
    </style>
  </head>
  <body>
    <div id="${device}">
      <h1>${device} manual</h1>
      <div id="timeline-${device}" class="timeline"></div>
    </div>
  </body>
</html>
EOF
  done
done
