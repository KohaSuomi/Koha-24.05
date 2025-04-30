import { createApp } from "vue";
import { createPinia } from "pinia";

import { library } from "@fortawesome/fontawesome-svg-core";
import {
    faPlus,
    faMinus,
    faPencil,
    faTrash,
    faSpinner,
} from "@fortawesome/free-solid-svg-icons";
import { FontAwesomeIcon } from "@fortawesome/vue-fontawesome";
import vSelect from "vue-select";

library.add(faPlus, faMinus, faPencil, faTrash, faSpinner);

const pinia = createPinia();


import App from "../components/HoldPickupShelves/Main.vue";
import i18n from "../i18n";

const view = document.getElementById('hold-pickup-shelves-view');
if (view) {
    const app = createApp(App, {
        library_id: view.getAttribute('data-library-id'),
        biblio_id: view.getAttribute('data-biblio-id'),
    });
    const rootComponent = app
        .use(i18n)
        .use(pinia)
        .component("font-awesome-icon", FontAwesomeIcon)
        .component("v-select", vSelect);

    app.config.unwrapInjectedRef = true;
    app.mount(view);
}