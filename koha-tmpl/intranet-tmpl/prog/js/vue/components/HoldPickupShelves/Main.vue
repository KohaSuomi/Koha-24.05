<template>
    <div class="form-group" v-if="shelves.length > 0">
        <label for="hold_pickup_shelf_id">Select available shelf</label>
        <select class="form-control" v-model="selectedShelf">
            <option v-for="shelf in shelves" :key="shelf.hold_pickup_shelf_id" :value="shelf.hold_pickup_shelf_id">
                {{ shelf.shelf_name }}
            </option>
        </select>
    </div>
</template>
<script>
import { APIClient } from "../../fetch/api-client.js";
export default {
    data() {
        return {
            shelves: [],
            selectedShelf: null,
            biblio_id: null,
            library_id: null
        }
    },
    async beforeMount() {
        await this.getParameters().then(() => {
            this.getShelves();
        });
    },
    watch: {
        selectedShelf() {
            const hiddenInput = document.getElementsByName("hold_pickup_shelf_id")[0];
            if (hiddenInput) {
                hiddenInput.value = this.selectedShelf;
            }
        }
    },
    methods: {
        async getShelves() {
            const client = APIClient.hold_pickup_shelves;
            this.shelves = await client.available.getAll({},{biblio_id: this.biblio_id, library_id: this.library_id});
            if (this.shelves.length > 0) {
                this.selectedShelf = this.shelves[0].hold_pickup_shelf_id;
            }
        },
        async getParameters() {
            this.biblio_id = document.getElementsByName("biblionumber")[0].value;
            this.library_id = document.getElementsByName("diffBranch")[0].value;
        }
    }
};
</script>