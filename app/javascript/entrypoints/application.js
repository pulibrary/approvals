/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

import {createApp} from "vue";
import lux from "lux-design-system";
import "lux-design-system/dist/style.css";
import eventDateModal from "../components/eventDateModal.vue";
import eventTitleInputWrapper from "../components/eventTitleInputWrapper.vue";
import hoursCalculator from "../components/hoursCalculator.vue";
import travelEstimateForm from "../components/travelEstimateForm.vue";
import travelRequestButton from "../components/travelRequestButton.vue";
import travelRequestDatePickers from "../components/travelRequestDatePickers.vue";
import '../../assets/stylesheets/application.scss';

// We import Rails, because without it, the vite dev
// server does not seem to have access to it.  However,
// we don't call Rails.start(), since Rails seems to handle
// that by itself.
// eslint-disable-next-line no-unused-vars
import Rails from "@rails/ujs";

// Create a factory function that will create vue
// apps, which we can then mount to any element with
// the class .lux
const app = createApp({});
const createMyApp = () => createApp(app);

// Rails.start();

document.addEventListener("DOMContentLoaded", () => {
    const elements = document.getElementsByClassName("lux");
    for (let i = 0; i < elements.length; i++) {
        // Call our factory function, then add all the lux components
        // and approvals components to it
        createMyApp().use(lux)
            .component('event-date-modal', eventDateModal)
            .component('event-title-input-wrapper', eventTitleInputWrapper)
            .component('hours-calculator', hoursCalculator)
            .component('travel-estimate-form', travelEstimateForm)
            .component('travel-request-button', travelRequestButton)
            .component('travel-request-date-pickers', travelRequestDatePickers)
            .mount(elements[i]);
    }
});

