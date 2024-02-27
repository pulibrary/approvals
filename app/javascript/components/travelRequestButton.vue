<template>
  <div>
    <lux-input-button
      id="submit-travel-request"
      type="button"
      variation="solid"
      @button-clicked="submitTravelRequest($event)"
    >
      Submit Request
    </lux-input-button>
    <event-date-modal
      :show-modal="showModal"
      @closeModal="close"
    >
      <div slot="body">
        <p>It looks like you have a date in the event title. Please remove before submitting</p>
        <br>
        <p>Detected: {{ matchedDate() }}</p>
      </div>
    </event-date-modal>
  </div>
</template>

<script>
/* eslint-disable vue/require-default-prop, no-unused-vars, vue/require-prop-type-constructor */
import eventDateModal from './eventDateModal.vue';

export default {
    name: "TravelEventButton",
    components: {
        eventDateModal
    },
    props: {
        eventTitle: "",
        form: HTMLDivElement
    },
    data: function() {
        return {
            showModal: false
        };
    },
    methods: {
        submitTravelRequest(event) {
            const form = document.querySelector(".travel-form");
            if (/\d{2,4}/.test(document.querySelector("#displayInput").value)) {
                if (form.checkValidity()) {
                    this.showModal = true;
                } else {
                    form.reportValidity();
                }
            } else {
                if (form.checkValidity()) {
                    form.submit();
                } else {
                    form.reportValidity();
                }
            }
      
        },
        close() {
            this.showModal = false;
        },
        matchedDate() {
            const title = document.querySelector("#displayInput");
            if (title === null) {
                return "";
            }

            return title.value.match(/\d{2,4}/)[0];
        }
    }
};
</script>

<style scoped>

</style>
