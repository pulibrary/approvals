<template>
  <div class="event-title-container">
    <input-autocomplete
      id="travel_request_event_requests_attributes_0_recurring_event_id"
      required
      name="travel_request[event_requests_attributes][0][recurring_event_id]"
      label="Event Name"
      :default-value="defaultValue"
      :items="items"
      autocomplete="off"
      :helper="helperText"
      @input="checkForDate($event)"
    />
    <div
      v-if="helperText"
      class="lux-helper"
    >
      {{ helperText }}
    </div>
  </div>
</template>

<script>
/* eslint-disable vue/require-default-prop, vue/require-prop-types,  vue/require-prop-type-constructor */
export default {
    name: "EventTitleInputWrapper",
    props: {
        defaultValue: "",
        items: Array
    },
    data: function(){
        return {
            helperText: ""
        };
    },
    methods: {
        checkForDate(e) {
            if(/\d{2,4}/.test(e)){
                this.helperText = "It looks like you have a date in this field. Please remove.";
            } else {
                this.helperText = "";
            }
        }
    }
};
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
