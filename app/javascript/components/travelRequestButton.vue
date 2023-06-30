<template>
  <div>
    <input-button id="submit-travel-request" @button-clicked="submitTravelRequest($event)" type="button" variation="solid">Submit Request</input-button>
    <event-date-modal :showModal="showModal" v-on:closeModal="close">
      <div slot="body">
        <p>It looks like you have a date in the event title. Please remove before submitting</p>
        <br>
        <p>Detected: {{ matchedDate() }}</p>
      </div>
    </event-date-modal>
  </div>
</template>

<script>
import eventDateModal from './eventDateModal.vue'

export default {
  name: "travelEventButton",
  components: {
    eventDateModal
  },
  data: function() {
    return {
      showModal: false
    }
  },
  props: {
    eventTitle: "",
    form: HTMLDivElement
  },
  methods: {
    submitTravelRequest(event) {
      var form = document.querySelector(".travel-form")
      if (/\d{2,4}/.test(document.querySelector("#displayInput").value)) {
        if (form.checkValidity()) {
          this.showModal = true
        } else {
          form.reportValidity()
        }
      } else {
        form.reportValidity()
        form.submit()
      }
      
    },
    close() {
      this.showModal = false
    },
    matchedDate() {
      var title = document.querySelector("#displayInput")
      if (title === null) {
        return ""
      }

      return title.value.match(/\d{2,4}/)[0]
    }
  }
}
</script>

<style scoped>

</style>