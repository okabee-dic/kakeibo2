# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
window.draw_graph = ->
  ctx = document.getElementById("linegraph").getContext('2d')
  myChart = new Chart(ctx, {
    type: 'line',
    data: {
      labels: gon.labels,
      datasets: [{
        label: '支出',
        data: gon.spends,
        lineTension: 0,
        borderColor: "rgba(255,153,51,0.9)",
        backgroundColor: "rgba(255,153,51,0.4)"
      },
      {
        label: '収入',
        data: gon.incomes,
        lineTension: 0,
        borderColor: "rgba(153,255,51,0.9)",
        backgroundColor: "rgba(153,255,51,0.0)"
      },
      {
        label: '合計',
        data: gon.totals,
        lineTension: 0,
        borderColor: "rgba(51,133,222,0.6)",
        backgroundColor: "rgba(51,133,222,0.2)",
      }
      ]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false
    }
  })
