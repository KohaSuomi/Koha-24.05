<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="hold_pickup_shelves_edit">
        <h1 v-if="hold_pickup_shelf.shelf_name">
            {{
                $__("Edit pickup shelf #%s").format(
                    hold_pickup_shelf.shelf_name
                )
            }}
        </h1>
        <h1 v-else>{{ $__("Add pickup shelf") }}</h1>
        <form @submit="onSubmit($event)">
            <fieldset class="rows">
                <ol>
                    <li>
                        <label class="required" for="library_id">
                            {{ $__("Library ID") }}:
                        </label>
                        <input
                            id="library_id"
                            v-model="hold_pickup_shelf.library_id"
                            required
                        />
                        <span class="required">{{ $__("Required") }}</span>
                    </li>
                    <li>
                        <label class="required" for="shelf_name">
                            {{ $__("Shelf name") }}:
                        </label>
                        <input
                            id="shelf_name"
                            v-model="hold_pickup_shelf.shelf_name"
                            required
                        />
                        <span class="required">{{ $__("Required") }}</span>
                    </li>
                    <li>
                        <label class="required" for="items_limit">
                            {{ $__("Items limit") }}:
                        </label>
                        <input
                            id="items_limit"
                            v-model="hold_pickup_shelf.items_limit"
                            required
                        />
                        <span class="required">{{ $__("Required") }}</span>
                    </li>
                </ol>
            </fieldset>
            <fieldset class="action">
                <input
                    type="submit"
                    class="btn btn-primary"
                    :value="$__('Submit')"
                />
                <router-link
                    :to="{ name: 'HoldPickupShelvesList' }"
                    role="button"
                    class="cancel"
                    >{{ $__("Cancel") }}</router-link
                >
            </fieldset>
        </form>
    </div>
</template>

<script>
import { inject } from "vue";
import { setMessage, setError, setWarning } from "../../../messages";
import { APIClient } from "../../../fetch/api-client.js";

export default {
    setup() {
        const { setMessage } = inject("mainStore");
        return {
            setMessage,
        };
    },
    data() {
        return {
            hold_pickup_shelf: {
                hold_pickup_shelf_id: null,
                shelf_name: "",
                library_id: "",
                items_limit: 0,
            },
            initialized: false,
        };
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            if (to.params.hold_pickup_shelf_id) {
                vm.getHoldPickupShelf(to.params.hold_pickup_shelf_id);
            } else {
                vm.initialized = true;
            }
        });
    },
    methods: {
        async getHoldPickupShelf(hold_pickup_shelf_id) {
            const client = APIClient.hold_pickup_shelves;
            client.hold_pickup_shelves.get(hold_pickup_shelf_id).then(
                hold_pickup_shelf => {
                    this.hold_pickup_shelf = hold_pickup_shelf;
                    this.hold_pickup_shelf_id = hold_pickup_shelf_id;
                    this.initialized = true;
                },
                error => {}
            );
        },
        onSubmit(e) {
            e.preventDefault();
            const client = APIClient.hold_pickup_shelves;
            let response;
            // RO attribute
            delete this.hold_pickup_shelf.hold_pickup_shelf_id;
            if (this.hold_pickup_shelf_id) {
                // update
                response = client.hold_pickup_shelves
                    .update(this.hold_pickup_shelf, this.hold_pickup_shelf_id)
                    .then(
                        success => {
                            setMessage(this.$__("Hold pickup shelf updated!"));
                            this.$router.push({ name: "HoldPickupShelvesList" });
                        },
                        error => {}
                    );
            } else {
                response = client.hold_pickup_shelves
                    .create(this.hold_pickup_shelf)
                    .then(
                        success => {
                            setMessage(this.$__("Hold pickup shelf created!"));
                            this.$router.push({ name: "HoldPickupShelvesList" });
                        },
                        error => {}
                    );
            }
        },
    },
};
</script>
