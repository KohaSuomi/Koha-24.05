<template>
    <div class="form-group" v-if="shelves.length > 0">
        <label for="hold_pickup_shelf_id">{{ $__('Select available shelf') }}</label>
        <select class="form-control" v-model="selectedShelf">
            <option value=""></option>
            <option v-for="shelf in shelves" :key="shelf.hold_pickup_shelf_id" :value="shelf.hold_pickup_shelf_id">
                {{ shelf.shelf_name }}
            </option>
        </select>
    </div>
    <div v-else>
        <p>{{ $__('No available pickup shelves') }}</p>
    </div>
</template>
<style scoped>
    .form-group {
        margin: 20px 0;
        max-width: 400px;
    }
</style>
<script>
import { APIClient } from "../../fetch/api-client.js";
export default {
    props: {
        biblio_id: {
            type: Number,
            required: true
        },
        library_id: {
            type: String,
            required: true
        }
    },
    data() {
        return {
            shelves: [],
            selectedShelf: null,
        }
    },
    async beforeMount() {
        this.getShelves();
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
        }
    }
};
</script>