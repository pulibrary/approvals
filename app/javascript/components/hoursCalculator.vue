<template>
  <grid-item columns="lg-12 sm-12">

    <date-picker id="absence_request_date"
      name="absence_request[start_date]"
      label="Date range"
      mode="range"
      placeholder="9/2/2019 - 9/12/2019"
      @updateInput="setHours($event)"
      :defaultDates="defaultDates">
      </date-picker>


    <input type="hidden" id="absence_request_start_date" name="absence_request[start_date]" :value="localStartDate">
    <input type="hidden" id="absence_request_end_date" name="absence_request[end_date]" :value="localEndDate">

    <input-text id="absence_request_hours_requested" name="absence_request[hours_requested]" label="Total hours requested" placeholder="111 hours" :value="localHoursReqested" required></input-text>
  </grid-item>
</template>

<script>
export default {
  name: "hoursCalculator",
  data: function () {
    return {
      localHoursReqested: this.hoursRequested,
      localStartDate: this.startDate,
      localEndDate: this.endDate,
      defaultDates: { start: new Date(this.startDate), end: new Date(this.endDate) }
    }
  },
  props: {
    holidays: {
     type: Array,
    },
    hoursPerDay: {},
    name: {},
    startDate: {},
    endDate: {},
    hoursRequested: { }
  },
  methods: {
    setHours(date_range) {
      this.localHoursReqested = this.calculateTotalHours(date_range);
    },
    calculateTotalHours(date_range) {
      var range = date_range.split(' - ');

      this.localStartDate = range[0];
      this.localEndDate = range[1];

      var start_date = new Date(this.localStartDate);
      var end_date = new Date(this.localEndDate);
      // console.log(date_range)
      // console.log(range[0])
      var date_array = this.getDates(start_date, end_date);

      var filtered = date_array.filter(this.isWorkday);
      return this.totalHours(filtered);
    },
    addDays(start_date, days) {
        var date = new Date(start_date);
        date.setDate(date.getDate() + days);
        return date;
    },
    getDates(start_date, end_date) {
        var dateArray = new Array();
        var currentDate = start_date;
        while (currentDate <= end_date) {
            dateArray.push(new Date (currentDate));
            currentDate = this.addDays(currentDate, 1);
        }
        return dateArray;
    },
    isWorkday(value) {
      if(value.getUTCDay() != 0 && value.getUTCDay() != 6 && !this.isHoliday(value)){
        return value;
      }
    },
    totalHours(filtered) {
      var totalWorkDays = filtered.length * this.hoursPerDay;

      return totalWorkDays;
    },
    isHoliday(date){
      var date_str = [date.getUTCFullYear(), this.pad(date.getUTCMonth()+1,2), this.pad(date.getUTCDate(),2)].join('-');
      return this.holidays.includes(date_str);
    },
    pad(num, size) {
      var s = "0" + num;
      return s.substr(s.length-size);
    }
  },
}
</script>

<style scoped>
p {
  font-size: 2em;
  text-align: center;
}
</style>
