<template>
    <div v-if="shelves.length > 0">
        <div class="row">
            <div class="col-md-12"><h4>{{ $__('Selected pickup shelf') }}</h4></div>
            <div class="col-md-6">
                <div class="d-flex align-items-center">
                    <select id="hold_pickup_shelf_id" class="form-control me-2" v-model="hold_pickup_shelf_id">
                        <option value=""></option>
                        <option v-for="shelf in shelves" :key="shelf.hold_pickup_shelf_id" :value="shelf.hold_pickup_shelf_id">
                            {{ shelf.shelf_name }}
                        </option>
                    </select>
                </div>
            </div>
            <div class="col-md-2 no-gutters">
                <button class="btn btn-primary" @click="lockShelf($event)">
                    <i class="fas fa-lock"></i>
                </button>
            </div>
        </div>
    </div>
    <div v-else>
        <div class="spinner-border text-primary" role="status">
            <span class="visually-hidden">{{ $__('Loading...') }}</span>
        </div>
    </div>
</template>
<style scoped>
    .no-gutters {
        margin-right: 0 !important;
        margin-left: 0 !important;
        padding-right: 0 !important;
        padding-left: 0 !important;
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
        },
        patron_id: {
            type: Number,
            required: true
        }
    },
    data() {
        return {
            shelves: [],
            hold_pickup_shelf: {},
            hold_pickup_shelf_id: null,
        }
    },
    async beforeMount() {
        this.getShelves();
    },
    watch: {
        selectedShelfId() {
            const hiddenInput = document.getElementsByName("hold_pickup_shelf_id")[0];
            if (hiddenInput) {
                hiddenInput.value = this.hold_pickup_shelf_id;
            }
        }
    },
    methods: {
        async getShelves() {
            const client = APIClient.hold_pickup_shelves;
            this.shelves = await client.available.getAll({},{biblio_id: this.biblio_id, library_id: this.library_id, patron_id: this.patron_id});
            if (this.shelves.length > 0) {
                this.hold_pickup_shelf_id = this.shelves[0].hold_pickup_shelf_id;
                this.hold_pickup_shelf = this.shelves[0];
            }
        },
        lockShelf(e) {
            e.preventDefault();
            const client = APIClient.hold_pickup_shelves;
            if (this.hold_pickup_shelf_id) {
                const locked_date = new Date();
                client.hold_pickup_shelves.patch(this.hold_pickup_shelf_id, { locked: true, locked_date: locked_date })
                    .then(() => {
                        this.getShelves();
                    })
                    .catch(error => {
                        console.error(error);
                    });
            }
        }
    }
};
</script>