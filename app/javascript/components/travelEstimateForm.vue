<template>
  <grid-container>
    <grid-item columns="lg-12 sm-12" :offset="true">
      <input-button type="button" variation="text"
        @button-clicked="addExpense()">
        <lux-icon-base width="12" height="12" icon-name="refresh">
          <lux-icon-refresh></lux-icon-refresh>
        </lux-icon-base> Add Expense</input-button>
    </grid-item>
    <grid-item columns="lg-12 sm-12" v-for="expense in expenseData">
      <grid-container>
        <grid-item columns="lg-2 sm-12">
          <input-select label="Expense Type" name="travel_request[estimates][cost_type]"
              id="travel_request_estimates_cost_type"
              :value="expense.cost_type" width="expand"
              :options="cost_types" required=true></input-select>
        </grid-item>
        <grid-item columns="lg-2 sm-12">
          <input-text label="Occurrences" name="travel_request[estimates][recurrence]"
              id="travel_request_estimates_recurrence"
              @input="updateRecurrence($event, expense)"
              :value="expense.recurrence" width="expand" required=true></input-text>
        </grid-item>
        <grid-item columns="lg-2 sm-12">
          <input-text label="Cost per Occurrence" name="travel_request[estimates][amount]"
              id="travel_request_estimates_amount"
              @input="updateAmount($event, expense)"
              :value="expense.amount" width="expand" required=true></input-text>
        </grid-item>
        <grid-item columns="lg-4 sm-12">
          <input-text label="Note" name="travel_request[estimates][description]"
              id="travel_request_estimates_description"
              :value="expense.description" width="expand" required=true></input-text>
        </grid-item>
        <grid-item columns="lg-2 sm-12">
          <input-text label="Total"
              :value="setTotal(expense)" width="expand" disabled=true></input-text>
        </grid-item>
      </grid-container>
    </grid-item>
  </grid-container>
</template>

<script>
export default {
  name: "travelEstimateForm",
  data: function () {
    return {
      expenseData: this.expenses,
    }
  },
  props: {
    expenses: {
     type: Array,
     default: [{ cost_type: null, recurrence: 1, amount: 0, description: '' }]
    },
    cost_types: {
     type: Array,
     default: []
    },
  },
  methods: {
    addExpense() {
      this.expenseData.push({ cost_type: null, recurrence: 1, amount: 0, description: '' })
    },
    setTotal(expense) {
      return (expense.amount * expense.recurrence).toFixed(2)
    },
    updateRecurrence(inputVal, expense) {
      let foundIndex = this.expenseData.findIndex(x => x.id == expense.id)
      expense.recurrence = inputVal
      this.expenseData[foundIndex] = expense
    },
    updateAmount(inputVal, expense) {
      let foundIndex = this.expenseData.findIndex(x => x.id == expense.id)
      expense.amount = inputVal
      this.expenseData[foundIndex] = expense
    },
    normalizeAmount(amount) {
      return Number(amount).toFixed(2)
    }
  },
}
</script>

<style scoped>
</style>
