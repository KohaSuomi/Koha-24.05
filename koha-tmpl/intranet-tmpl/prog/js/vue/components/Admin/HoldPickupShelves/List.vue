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
        <div class="page-section">
            <KohaTable
                ref="table"
                v-bind="tableOptions"
                @edit="doEdit"
                @delete="doDelete"
            ></KohaTable>
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
                        title: __("Items limit"),
                        data: "items_limit",
                        searchable: true,
                        orderable: true,
                    },
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
                options: {embed: "library"},
            },
            initialized: true,
            hold_pickup_shelves: [],
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
    // beforeRouteEnter(to, from, next) {
    //     next(vm => {
    //         vm.listHoldPickupShelves().then(() => (vm.initialized = true));
    //     });
    // },
    methods: {
        async listHoldPickupShelves() {
            const client = APIClient.hold_pickup_shelves;
            await client.hold_pickup_shelves.getAll({}, {}, { "x-koha-embed": "library" }).then(
                hold_pickup_shelves => {
                    this.hold_pickup_shelves = hold_pickup_shelves;
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
    },
    components: {
        KohaTable,
        Toolbar,
        ToolbarButton,
    },
};
</script>
