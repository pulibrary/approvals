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

import Vue from "vue/dist/vue.esm";
import system from "lux-design-system";
import "lux-design-system/dist/system/system.css";
import "lux-design-system/dist/system/tokens/tokens.scss";
import eventDateModal from "../components/eventDateModal.vue";
import eventTitleInputWrapper from "../components/eventTitleInputWrapper.vue";
import hoursCalculator from "../components/hoursCalculator.vue";
import travelEstimateForm from "../components/travelEstimateForm.vue";
import travelRequestButton from "../components/travelRequestButton.vue";
import travelRequestDatePickers from "../components/travelRequestDatePickers.vue";
import Rails from '@rails/ujs';

Vue.use(system);

// create the LUX app and mount it to wrappers with class="lux"
document.addEventListener("DOMContentLoaded", () => {
    const elements = document.getElementsByClassName("lux");
    for (let i = 0; i < elements.length; i++) {
        new Vue({
            el: elements[i],
            components: {
                'event-date-modal': eventDateModal,
                'event-title-input-wrapper': eventTitleInputWrapper,
                'hours-calculator': hoursCalculator,
                'travel-estimate-form': travelEstimateForm,
                'travel-request-button': travelRequestButton,
                'travel-request-date-pickers': travelRequestDatePickers,
            }
        });
    }
});

Rails.start();
