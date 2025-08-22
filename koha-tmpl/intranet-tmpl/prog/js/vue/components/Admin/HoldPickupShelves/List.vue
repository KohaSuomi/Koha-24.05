<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="hold_pickup_shelves_list">
        <Toolbar>
            <ToolbarButton
                :to="{ name: 'HoldPickupShelvesFormAdd' }"
                icon="plus"
                :title="$__('New pickup shelf')"
            />
        </Toolbar>
        <h1>{{ title }}</h1>
        <div v-if="hold_pickup_shelves_any > 0" class="page-section">
            <KohaTable
                ref="table"
                v-bind="tableOptions"
                @edit="doEdit"
                @delete="doDelete"
            ></KohaTable>
        </div>
        <div v-else class="alert alert-info">
            {{ $__("There are no hold pickup shelves defined") }}
        </div>
    </div>
</template>

<script>
import Toolbar from "../../Toolbar.vue";
import ToolbarButton from "../../ToolbarButton.vue";
import { inject } from "vue";
import { APIClient } from "../../../fetch/api-client.js";
import KohaTable from "../../KohaTable.vue";

export default {
    props: {
        libraries: Array,
        categories: Array,
        biblio_level_itemtypes: Array,
    },
    data() {
        return {
            title: this.$__("Hold pickup shelves"),
            tableOptions: {
                columns: [
                    {
                        title: this.$__("ID"),
                        data: "hold_pickup_shelf_id",
                        searchable: true,
                    },
                    {
                        title: this.$__("Priority"),
                        data: "priority",
                        searchable: true,
                        orderable: true,
                        render: (data, type, row) => {
                            return `
                                <div style="display:flex;align-items:center;gap:2px;">
                                    <button type="button" class="priority-arrow-last" data-id="${row.hold_pickup_shelf_id}" data-priority="${data}" title="${this.$__('Set last priority')}" style="border:none;background:none;padding:0 2px;font-size:16px;">&#8659;</button>
                                    <button type="button" class="priority-arrow-down" data-id="${row.hold_pickup_shelf_id}" data-priority="${data}" title="${this.$__('Decrease priority')}" style="border:none;background:none;padding:0 2px;font-size:16px;">&#8595;</button>
                                    <span style="min-width:30px;display:inline-block;text-align:center;">${data !== null ? data : ''}</span>
                                    <button type="button" class="priority-arrow-up" data-id="${row.hold_pickup_shelf_id}" data-priority="${data}" title="${this.$__('Increase priority')}" style="border:none;background:none;padding:0 2px;font-size:16px;">&#8593;</button>
                                    <button type="button" class="priority-arrow-first" data-id="${row.hold_pickup_shelf_id}" data-priority="${data}" title="${this.$__('Set first priority')}" style="border:none;background:none;padding:0 2px;font-size:16px;">&#8657;</button>
                                </div>
                            `;
                        },
                    },
                    {
                        title: this.$__("Library name"),
                        data: "library.name",
                        searchable: true,
                    },
                    {
                        title: this.$__("Shelf name"),
                        data: "shelf_name",
                        searchable: true,
                    },
                    {
                        title: this.$__("Max items"),
                        data: "max_items",
                        searchable: true,
                        orderable: true,
                    },
                    {
                        title: this.$__("Weekday"),
                        data: "weekday",
                        searchable: true,
                        orderable: true,
                        render: data => {
                            return data
                                ? this.$__("%s").format(data)
                                : this.$__("Any");
                        },
                    },
                    {
                        title: this.$__("Patron category"),
                        data: "patron_category.name",
                        searchable: true,
                        orderable: true,
                        render: data => {
                            return data
                                ? data
                                : this.$__("Any");
                        },
                    },
                    {
                        title: this.$__("Biblio level itemtype"),
                        data: "biblio_itemtype",
                        searchable: true,
                        orderable: true,
                        render: data => {
                            return data
                                ? data
                                : this.$__("Any");
                        },
                    },
                    {
                        title: this.$__("Overflow shelf"),
                        data: "overflow_shelf",
                        searchable: true,
                        orderable: true,
                        render: data => (data === true ? this.$__("Yes") : this.$__("No")),
                    },
                    {
                        title: this.$__("Locked"),
                        data: "locked",
                        searchable: true,
                        orderable: true,
                        render: data => (data === true ? this.$__("Yes") : this.$__("No")),
                    }
                ],
                actions: {
                    "-1": [
                        "edit",
                        {
                            delete: {
                                text: this.$__("Delete"),
                                icon: "fa fa-trash",
                            },
                        },
                    ],
                },
                url: "/api/v1/holds/pickup_shelves",
                options: {embed: "library,patron_category", 
                          order: [[1, "asc"]]},
            },
            initialized: false,
            hold_pickup_shelves_any: 0,
        };
    },
    setup() {
        const { setWarning, setMessage, setError, setConfirmationDialog } =
            inject("mainStore");
        return {
            setWarning,
            setMessage,
            setError,
            setConfirmationDialog,
        };
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.anyHoldPickupShelves().then(() => (vm.initialized = true));
        });
    },
    watch: {
        initialized(newVal) {
            if (newVal) {
                this.$nextTick(() => {
                    const table = this.$el.querySelector("#hold_pickup_shelves_list .dataTable");
                    if (table) {
                        table.addEventListener("click", (event) => {
                            if (event.target && event.target.classList.contains("priority-arrow-down")) {
                                const priority = parseInt(event.target.getAttribute("data-priority"));
                                this.changePriority(event, priority + 1);
                            } else if (event.target && event.target.classList.contains("priority-arrow-up")) {
                                const priority = parseInt(event.target.getAttribute("data-priority"));
                                this.changePriority(event, priority - 1);
                            } else if (event.target && event.target.classList.contains("priority-arrow-last")) {
                                // Find the maximum priority value from the table rows
                                const table = event.target.closest("table");
                                let maxPriority = 0;
                                if (table) {
                                    const rows = table.querySelectorAll("tbody tr");
                                    rows.forEach(row => {
                                        const cell = row.querySelector('button[data-priority]');
                                        if (cell) {
                                            const p = parseInt(cell.getAttribute("data-priority"));
                                            if (!isNaN(p) && p > maxPriority) maxPriority = p;
                                        }
                                    });
                                }
                                this.changePriority(event, maxPriority);
                            } else if (event.target && event.target.classList.contains("priority-arrow-first")) {
                                const table = event.target.closest("table");
                                let minPriority = Infinity;
                                if (table) {
                                    const rows = table.querySelectorAll("tbody tr");
                                    rows.forEach(row => {
                                        const cell = row.querySelector('button[data-priority]');
                                        if (cell) {
                                            const p = parseInt(cell.getAttribute("data-priority"));
                                            if (!isNaN(p) && p < minPriority) minPriority = p;
                                        }
                                    });
                                }
                                this.changePriority(event, minPriority);
                            }
                        });
                    }
                });
            }
        }
    },
    methods: {
        async anyHoldPickupShelves() {
            const client = APIClient.hold_pickup_shelves;
            await client.hold_pickup_shelves.getAll({}, {_page: 1, _per_page: 1}).then(
                hold_pickup_shelves => {
                    this.hold_pickup_shelves_any = hold_pickup_shelves.length;
                },
                error => {}
            );
        },
        newHoldPickupShelf() {
            this.$router.push({ name: "HoldPickupShelvesFormAdd" });
        },
        doEdit: function ({ hold_pickup_shelf_id }, dt, event) {
            this.$router.push({
                name: "HoldPickupShelvesFormAddEdit",
                params: { hold_pickup_shelf_id },
            });
        },
        doDelete: function (hold_pickup_shelf, dt, event) {
            this.setConfirmationDialog(
                {
                    title: this.$__(
                        "Are you sure you want to delete this hold pickup shelf?"
                    ),
                    message: hold_pickup_shelf.shelf_name,
                    accept_label: this.$__("Yes, delete"),
                    cancel_label: this.$__("No, do not delete"),
                },
                () => {
                    const client = APIClient.hold_pickup_shelves;
                    client.hold_pickup_shelves.delete(hold_pickup_shelf.hold_pickup_shelf_id).then(
                        success => {
                            this.setMessage(
                                this.$__(
                                    "Hold pickup shelf '%s' deleted"
                                ).format(hold_pickup_shelf.shelf_name),
                                true
                            );
                            dt.draw();
                        },
                        error => {}
                    );
                }
            );
        },
        changePriority: function (event, priority) {
            const input = event.target;
            const hold_pickup_shelf_id = input.getAttribute("data-id");
            if (isNaN(priority) || priority < 1) {
                this.setWarning(this.$__("Priority must be a positive integer"));
                return;
            }
            const client = APIClient.hold_pickup_shelves;
            client.hold_pickup_shelves.patch(hold_pickup_shelf_id, {priority: priority}).then(
                success => {
                    this.setMessage(this.$__("Priority updated successfully"));
                    this.$refs.table.redraw("/api/v1/holds/pickup_shelves");
                },
                error => {
                    this.setError(this.$__("Failed to update priority"));
                }
            );
        },
    },
    components: {
        KohaTable,
        Toolbar,
        ToolbarButton,
    },
};
</script>
