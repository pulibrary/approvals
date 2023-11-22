<template>
  <div>
    <date-picker
      id="travel_request_event_requests_attributes_0_event_dates"
      label="Event Dates"
      mode="range"
      width="expand"
      required
      name="travel_request[event_requests_attributes][0][event_dates]"
      :disabled-dates="event_disabled_dates"
      :default-dates="eventDates"
      @updateInput="updateTravelDates($event)"
    />
    <date-picker
      id="travel_request_travel_dates"
      label="Travel Dates"
      mode="range"
      width="expand"
      name="travel_request[travel_dates]"
      :disabled-dates="travel_disabled_dates"
      :default-dates="travelDates"
    />
  </div>
</template>

<script>
/* eslint-disable vue/prop-name-casing, vue/require-valid-default-prop */
export default {
    name: "TravelRequestDatePickers",
    props: {
        event_disabled_dates: {
            type: Array,
            default: []
        },
        travel_disabled_dates: {
            type: Array,
            default: []
        },
        event_dates: {
            type: Object,
            default: null
        },
        travel_dates: {
            type: Object,
            default: null
        },
        today: {
            type: Date,
            default: ""
        },
    },
    data: function () {
        return {
            travelDates: this.travel_dates,
            eventDates: this.event_dates,
        };
    },
    methods: {
        updateTravelDates(eventDateRange) {
            const eventDates = eventDateRange.split(' - ');
            const eventStart = new Date(eventDates[0]);
            const eventEnd = new Date(eventDates[1]);
            if(this.travelDates.start.toString() === this.today.toString() &&
          this.travelDates.end.toString() === this.today.toString()){
                this.travelDates.start = eventStart;
                this.travelDates.end = eventEnd;
            }
        }
    },
};
</script>

<style scoped>

</style>
