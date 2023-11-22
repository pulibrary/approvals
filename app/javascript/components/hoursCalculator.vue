<template>
  <div>
    <date-picker
      id="absence_request_date"
      name="absence_request[start_date]"
      label="Date range"
      mode="range"
      width="expand"
      placeholder="9/2/2019 - 9/12/2019"
      :holidays="holidays"
      :default-dates="defaultDates"
      @updateInput="setHours($event)"
    />


    <input
      id="absence_request_start_date"
      type="hidden"
      name="absence_request[start_date]"
      :value="localStartDate"
    >
    <input
      id="absence_request_end_date"
      type="hidden"
      name="absence_request[end_date]"
      :value="localEndDate"
    >

    <input-text
      id="absence_request_hours_requested"
      name="absence_request[hours_requested]"
      width="expand"
      label="Total hours requested"
      :helper="helperCaption"
      :value="localHoursReqested"
      required
      @input="updateCaption($event)"
    />
  </div>
</template>

<script>
/* eslint-disable vue/require-prop-types, vue/require-valid-default-prop, vue/require-default-prop */
export default {
    name: "HoursCalculator",
    props: {
        holidays: {
            type: Array,
        },
        hoursPerDay: {},
        name: {},
        startDate: {},
        endDate: {},
        hoursRequested: {
            type: Number,
            default: 0,
        },
    },
    data: function () {
        return {
            nonWorkDays: 0,
            helperCaption: "",
            localHoursReqested: this.hoursRequested,
            localStartDate: this.startDate,
            localEndDate: this.endDate,
            defaultDates: { start: new Date(this.startDate), end: new Date(this.endDate) }
        };
    },
    created: function () {
        this.updateCaption(this.hoursPerDay);
    },
    methods: {
        setHours(date_range) {
            this.nonWorkDays = 0;
            this.localHoursReqested = this.calculateTotalHours(date_range);
            this.updateCaption(this.localHoursReqested);
        },
        calculateTotalHours(date_range) {
            const range = date_range.split(' - ');

            this.localStartDate = range[0];
            this.localEndDate = range[1];

            const start_date = new Date(this.localStartDate);
            const end_date = new Date(this.localEndDate);
            // console.log(date_range)
            // console.log(range[0])
            const date_array = this.getDates(start_date, end_date);

            const filtered = date_array.filter(this.isWorkday);
            return this.totalHours(filtered);
        },
        addDays(start_date, days) {
            const date = new Date(start_date);
            date.setDate(date.getDate() + days);
            return date;
        },
        getDates(start_date, end_date) {
            const dateArray = new Array();
            let currentDate = start_date;
            while (currentDate <= end_date) {
                dateArray.push(new Date (currentDate));
                currentDate = this.addDays(currentDate, 1);
            }
            return dateArray;
        },
        isWorkday(value) {
            if(value.getUTCDay() != 0 && value.getUTCDay() != 6 && !this.isHoliday(value)){
                return value;
            } else {
                this.nonWorkDays = this.nonWorkDays + 1;
            }
        },
        totalHours(filtered) {
            const totalWorkDays = filtered.length * this.hoursPerDay;

            return totalWorkDays;
        },
        isHoliday(date){
            const date_str = [date.getUTCFullYear(), this.pad(date.getUTCMonth()+1,2), this.pad(date.getUTCDate(),2)].join('-');
            return this.holidays.includes(date_str);
        },
        hoursToDays(hours){
            return hours / this.hoursPerDay;
        },
        updateCaption(value){
            const val = Number(value);
            if(val) {
                this.localHoursReqested = val;
                this.helperCaption = this.localHoursReqested + " hours = " + this.hoursToDays(this.localHoursReqested).toFixed(2) + " days (" + this.nonWorkDays + " holiday and weekend dates excluded.)";
            }
        },
        pad(num, size) {
            const s = "0" + num;
            return s.substr(s.length-size);
        }
    },
};
</script>

<style scoped>
p {
  font-size: 2em;
  text-align: center;
}
</style>
