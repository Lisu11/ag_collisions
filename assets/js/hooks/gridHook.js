import { createGrid, ModuleRegistry, AllCommunityModule, themeQuartz, colorSchemeDarkBlue} from "ag-grid-community";
import {AllEnterpriseModule, LicenseManager} from "ag-grid-enterprise";


// TODO: select only needed modules
ModuleRegistry.registerModules([AllCommunityModule, AllEnterpriseModule]);

function createAgGrid(node) {
    node.grid = createGrid(node.el, {
        theme: themeQuartz.withPart(colorSchemeDarkBlue),
        columnDefs: [
        { field: "date" },
        { field: "district" },
        { field: "severity" },
        { field: "casualties" },
        { field: "weather" },
        { field: "road" }
        ],
        rowModelType: "serverSide",
        pagination: true,
        paginationPageSize: 50,
        paginationPageSizeSelector: [50],
        serverSideDatasource: {
        getRows: (params) => {
            node.pushEventTo("#"+node.el.id, "get-rows", {
            startRow: params.request.startRow,
            endRow: params.request.endRow
            }).then(
            ([{value: {reply}}]) => {
                params.success({
                rowData: reply.data,
                rowCount: reply.count
                });
            },
            (error) => {
                params.fail()
            }
            )

            
        }
        },
        onRowClicked: (event) => {
        // TODO: row deselect
        // https://www.ag-grid.com/javascript-data-grid/row-events/#reference-rowNodeEvents-rowSelected

        node.pushEventTo("#"+node.el.id,"row-selected", {uuid: event.data.uuid});
        }
    });
}

export const GridHook = {
    mounted() {      
      this.handleEvent("refresh-grid", () => {
        if(this.grid) {
            this.grid.refreshServerSide()
        } else {
            createAgGrid(this)
        }
      });
    }
  };