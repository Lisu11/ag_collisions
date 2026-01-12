import { createGrid, ModuleRegistry, AllCommunityModule, themeQuartz, colorSchemeDarkBlue} from "ag-grid-community";
import {AllEnterpriseModule, LicenseManager} from "ag-grid-enterprise";


// TODO: select only needed modules
ModuleRegistry.registerModules([AllCommunityModule, AllEnterpriseModule]);

LicenseManager.setLicenseKey("[TRIAL]_this_{AG_Charts_and_AG_Grid}_Enterprise_key_{AG-117499}_is_granted_for_evaluation_only___Use_in_production_is_not_permitted___Please_report_misuse_to_legal@ag-grid.com___For_help_with_purchasing_a_production_key_please_contact_info@ag-grid.com___You_are_granted_a_{Single_Application}_Developer_License_for_one_application_only___All_Front-End_JavaScript_developers_working_on_the_application_would_need_to_be_licensed___This_key_will_deactivate_on_{10 February 2026}____[v3]_[0102]_MTc3MDY4MTYwMDAwMA==a9b79adbe582d613510d294b70e2387d")

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