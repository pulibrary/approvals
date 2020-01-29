<template>
  <div>
      <date-picker label="Event Dates" mode="range" width="expand" required
        id="travel_request_event_requests_attributes_0_event_dates"
        name="travel_request[event_requests_attributes][0][event_dates]"
        :disabled-dates="event_disabled_dates"
        :default-dates="eventDates"
        @updateInput="updateTravelDates($event)"
      ></date-picker>
      <date-picker label="Travel Dates" mode="range" width="expand"
        name="travel_request[travel_dates]" id="travel_request_travel_dates"
        :disabled-dates="travel_disabled_dates"
        :default-dates="travelDates"
      ></date-picker>
  </div>
</template>

<script>
export default {
  name: "travelRequestDatePickers",
  data: function () {
    return {
      travelDates: this.travel_dates,
      eventDates: this.event_dates,
    }
  },
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
  methods: {
    updateTravelDates(eventDateRange) {
      var eventDates = eventDateRange.split(' - ')
      var eventStart = new Date(eventDates[0])
      var eventEnd = new Date(eventDates[1])
      if( this.travelDates.start.toString() === this.today.toString() &&
          this.travelDates.end.toString() === this.today.toString()){
        this.travelDates.start = eventStart
        this.travelDates.end = eventEnd
      }
    }
  },
}
</script>

<style scoped>

</style>
