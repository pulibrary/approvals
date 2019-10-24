<template>
  <grid-container>
    <grid-item columns="lg-12 sm-12 auto" :offset="true">
      <input-button type="button" id="add-expense-button" variation="text"
        @button-clicked="addExpense()">
        <lux-icon-base width="12" height="12" icon-name="refresh">
          <lux-icon-refresh></lux-icon-refresh>
        </lux-icon-base> Add Expense</input-button>
    </grid-item>
    <grid-item columns="lg-12 sm-12" v-for="expense in expenseData">
      <grid-container>
        <grid-item :vertical="center" columns="lg-1 sm-12">
          <input-button class="button-delete-row" type="button" variation="text"
            @button-clicked="deleteExpense(expense)">
            <lux-icon-base width="25" height="25" icon-name="denied" icon-color="red">
              <lux-icon-denied></lux-icon-denied>
            </lux-icon-base>
          </input-button>
          <input type="hidden" name="travel_request[estimates][][id]" :value="expense.id"/>
        </grid-item>
        <grid-item columns="lg-2 sm-12">
          <input-select label="Expense Type" name="travel_request[estimates][][cost_type]"
              id="travel_request_estimates_cost_type"
              :value="expense.cost_type" width="expand"
              :options="cost_types" required=true></input-select>
        </grid-item>
        <grid-item columns="lg-1 sm-12">
          <input-text label="Occurrences" name="travel_request[estimates][][recurrence]"
              id="travel_request_estimates_recurrence"
              @input="updateRecurrence($event, expense)"
              :value="expense.recurrence" width="expand" required=true></input-text>
        </grid-item>
        <grid-item columns="lg-2 sm-12">
          <input-text label="Cost" name="travel_request[estimates][][amount]"
              id="travel_request_estimates_amount"
              @input="updateAmount($event, expense)"
              :value="expense.amount" width="expand" required=true></input-text>
        </grid-item>
        <grid-item columns="lg-4 sm-12">
          <input-text label="Note" name="travel_request[estimates][][description]"
              id="travel_request_estimates_description"
              :value="expense.description" width="expand"></input-text>
        </grid-item>
        <grid-item columns="lg-2 sm-12">
          <input-text label="Total"
              :value="setLineItemTotal(expense)" width="expand" disabled=true></input-text>
        </grid-item>
      </grid-container>
    </grid-item>
    <grid-item columns="lg-12 sm-12">
      <hr/>
    </grid-item>
    <grid-item columns="lg-10 sm-12 auto" :offset="true">
      <text-style variation="strong">Total:</text-style>
    </grid-item>
    <grid-item columns="lg-2 sm-12">
      <text-style id="expenses-total" variation="strong">${{ expensesTotal() }}</text-style>
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
     default: [{ id: null, cost_type: null, recurrence: 1, amount: 0, description: '' }]
    },
    cost_types: {
     type: Array,
     default: []
    },
  },
  methods: {
    addExpense() {
      this.expenseData.push({ id: null, cost_type: null, recurrence: 1, amount: 0, description: '' })
    },
    deleteExpense(expense) {
      let foundIndex = this.expenseData.findIndex(x => x.id == expense.id)
      this.expenseData.splice(foundIndex, 1)
    },
    setLineItemTotal(expense) {
      return (expense.amount * expense.recurrence).toFixed(2)
    },
    expensesTotal() {
      let total = 0
      let len = this.expenseData.length
      for (let i = 0; i < len; i++) {
        total = total + (this.expenseData[i].amount * this.expenseData[i].recurrence)
      }
      return total.toFixed(2)
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
