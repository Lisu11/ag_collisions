import { AgCharts, AllCommunityModule, ModuleRegistry } from 'ag-charts-community';
ModuleRegistry.registerModules([AllCommunityModule]);

function create_chart(node) {
    if(node.chart){
        node.chart.destroy()
    }
    
    let chart = AgCharts.create({
        container: node.el,
        data: JSON.parse(node.el.dataset.chartData),
        title: {text: "Collisions by Month"},
        theme: "ag-default-dark",
        seriesArea:{
            cornerRadius: 18
        },
        series: [{
        type: 'bar',
        xKey: 'month',
        yKey: 'collisions'
        }],
        background: {
            fill: '#1f2836',
          },
    });
    node.chart = chart;
}

export const ChartHook = {
    mounted() {
        create_chart(this)
    },
    updated() {
        create_chart(this)
    }
  };