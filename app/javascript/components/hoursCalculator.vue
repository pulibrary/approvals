<template>
  <grid-item columns="lg-12 sm-12">
    <!--<date-picker id="absence_request_start_date" name="absence_request[start_date]" label="Start Date" mode="range"></date-picker>-->
    
    <input-text id="bar" name="value" label="Date range" value="9/2/2019 - 9/12/2019" @inputblur="setHours($event)"></input-text>

    <input type="hidden" id="absence_request_start_date" name="absence_request[start_date]" :value="startDate">
    <input type="hidden" id="absence_request_end_date" name="absence_request[end_date]" :value="endDate">

    <input-text id="absence_request_hours_requested" name="absence_request[hours_requested]" label="Total hours requested" placeholder="111 hours" :value="hoursRequested" required></input-text>
  </grid-item>
</template>

<script>
export default {
  name: "hoursCalculator",
  data: function () {
    return {
      hoursRequested: "",
      startDate: this.startDate,
      endDate: this.endDate
    }
  },
  props: { 
    holidays: {
     type: Array,
    }, 
    hoursPerDay: {},
    name: {},
    startDate: {},
    endDate: {}
  },
  methods: {
    setHours(event) {
      this.hoursRequested = this.calculateTotalHours( event.value); 
    },
    calculateTotalHours(date_range) {
      var range = date_range.split(' - ');

      this.startDate = range[0];
      this.endDate = range[1];

      var start_date = new Date(this.startDate);
      var end_date = new Date(this.endDate);

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
