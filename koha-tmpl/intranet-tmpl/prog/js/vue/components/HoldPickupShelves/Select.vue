<template>
    <div :class="{'mt-2': error }">
        <div v-if="loading" class="alert alert-info">
            <i class="fas fa-spinner fa-spin"></i> {{ $__('Loading...') }}
        </div>
        <div v-else-if="shelves.length > 0">
            <div class="row">
                <div class="col-md-12">
                    <p><b>{{ $__('Select a pickup shelf') }}</b></p>
                </div>
                <div class="col-md-12" v-if="notification">
                    <div class="alert alert-warning">
                        <i class="fas fa-info-circle"></i> <b>{{ notification }}</b>
                        <button type="button" class="close" data-dismiss="alert" aria-label="Close" @click="notification = null">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                </div>
                <div class="col-md-6">
                    <select id="hold_pickup_shelf_id" class="form-control me-2" v-model="hold_pickup_shelf_id">
                        <option value=""></option>
                        <option v-for="shelf in shelves" :key="shelf.hold_pickup_shelf_id" :value="shelf.hold_pickup_shelf_id">
                            {{ shelf.shelf_name }}
                        </option>
                    </select>
                </div>
                <div class="col-md-2 no-gutters">
                    <button class="btn btn-primary" @click="lockShelf($event)">
                        <i class="fas fa-lock"></i>
                    </button>
                </div>
            </div>
        </div>
        <div v-else>
            <div class="alert alert-info">
                <i class="fas fa-info-circle"></i> {{ $__('No pickup shelves available') }}
            </div>
        </div>
    </div>
</template>
<style scoped>
    .mt-2 {
        margin-top: 15px !important;
    }
    .no-gutters {
        margin-right: 0 !important;
        margin-left: 0 !important;
        padding-right: 0 !important;
        padding-left: 0 !important;
    }
    .close {
        float: right !important;
        font-size: 18px !important;
        font-weight: bold !important;
        line-height: 1 !important;
        color: #000 !important;
        text-shadow: 0 1px 0 #fff !important;
    }
</style>
<script>
import { inject } from "vue";
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
        },
    },
    setup() {
        const { setError } = inject("mainStore");
        return {
            setError,
        };
    },
    data() {
        return {
            shelves: [],
            hold_pickup_shelf: {},
            hold_pickup_shelf_id: null,
            previous_shelf_id: null,
            realtimeInterval: null,
            notification: null,
            loading: true,
            error: false
        }
    },
    async mounted() {
        this.getShelves();
        this.startRealtimeCheck();
    },
    beforeUnmount() {
        this.stopRealtimeCheck();
    },
    watch: {
        hold_pickup_shelf_id() {
            const hiddenInput = document.getElementsByName("hold_pickup_shelf_id")[0];
            if (hiddenInput) {
                hiddenInput.value = this.hold_pickup_shelf_id;
            }
        }
    },
    methods: {
        async getShelves() {
            try {
                const client = APIClient.hold_pickup_shelves;
                this.shelves = await client.available.getAll({},{biblio_id: this.biblio_id, library_id: this.library_id, patron_id: this.patron_id});
                if (this.shelves.length > 0) {
                    this.hold_pickup_shelf_id = this.shelves[0].hold_pickup_shelf_id;
                    this.hold_pickup_shelf = this.shelves[0];
                    if (this.previous_shelf_id !== null && this.previous_shelf_id != this.hold_pickup_shelf_id) {
                        this.notification = this.$__("Pickup shelf changed to %s").format(this.hold_pickup_shelf.shelf_name);
                        setTimeout(() => {
                            this.notification = null;
                        }, 15000);
                    }
                    this.previous_shelf_id = this.hold_pickup_shelf_id;
                }
                this.loading = false;
            } catch (error) {
                this.shelves = [];
                this.error = true;
                this.setError(this.$__("Error fetching pickup shelves") + ": " + error.message);
                this.loading = false;
            }
        },
        lockShelf(e) {
            this.error = false;
            e.preventDefault();
            const client = APIClient.hold_pickup_shelves;
            if (this.hold_pickup_shelf_id) {
                const locked_date = new Date();
                client.hold_pickup_shelves.patch(this.hold_pickup_shelf_id, { locked: true, locked_date: locked_date })
                    .then(() => {
                        this.getShelves();
                    })
                    .catch(error => {
                        this.error = true;
                        this.setError(this.$__("Error locking pickup shelf") + ": " + error.message);
                    });
            }
        },
        startRealtimeCheck() {
            this.realtimeInterval = setInterval(() => {
                const holdFound2 = document.getElementById('hold-found2');
                if (holdFound2 && !holdFound2.classList.contains('in')) {
                    this.notification = null;
                    this.stopRealtimeCheck();
                    return;
                }
                if (this.hold_pickup_shelf_id) {
                    this.getShelves();
                }
            }, 5000); // Check every 5 seconds
        },
        stopRealtimeCheck() {
            if (this.realtimeInterval) {
                clearInterval(this.realtimeInterval);
            }
        }
    }
};
</script>