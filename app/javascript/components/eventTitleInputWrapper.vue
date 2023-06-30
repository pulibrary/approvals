<template>
  <div class="event-title-container">
    <input-autocomplete required
      id="travel_request_event_requests_attributes_0_recurring_event_id"
      name="travel_request[event_requests_attributes][0][recurring_event_id]"
      label="Event Name"
      :default-value="defaultValue"
      :items="items"
      autocomplete="off"
      :helper="helperText"
      v-on:input="checkForDate($event)"
    >
    </input-autocomplete>
    <div class="lux-helper" v-if="helperText">{{ helperText }}</div>
  </div>
</template>

<script>
export default {
  name: "eventTitleInputWrapper",
  data: function(){
    return {
      helperText: ""
    }
  },
  props: {
    defaultValue: "",
    items: Array
  },
  methods: {
    checkForDate(e) {
      if(/\d{2,4}/.test(e)){
        this.helperText = "It looks like you have a date in this field. Please remove."
      } else {
        this.helperText = ""
      }
    }
  }
}
</script>

<style>
  .lux-helper {
    margin-top: 8px;
    font-size: 14px;
    color: #6b7380;
  }

  .event-title-container {
    margin-bottom: 16px;
  }
</style>