<template>
  <grid-container class="expenses">
    <grid-item columns="lg-12 sm-12" class="expense-row-header">
      <grid-container>
        <grid-item vertical="center" columns="lg-1 sm-12" class="expense-delete">
          <text-style>Delete</text-style>
        </grid-item>
        <grid-item vertical="center" columns="lg-2 sm-12">
          <text-style id="expense-type-column">Expense Type</text-style>
        </grid-item>
        <grid-item vertical="center" columns="lg-1 sm-12">
          <text-style>Occurrences</text-style>
        </grid-item>
        <grid-item vertical="center" columns="lg-2 sm-12">
          <text-style>Cost per Occurrence</text-style>
        </grid-item>
        <grid-item vertical="center" columns="lg-4 sm-12">
         <text-style>Note</text-style>
        </grid-item>
        <grid-item vertical="center" columns="lg-2 sm-12">
          <text-style>Total</text-style>
        </grid-item>
      </grid-container>
    </grid-item>

    <grid-item columns="lg-12 sm-12" class="expense-row" v-for="expense in expenseData" v-bind:key="expense.id">
      <grid-container>
        <grid-item vertical="center" columns="lg-1 sm-12" class="expense-delete">
          <input-button class="button-delete-row" type="button" variation="text"
            @button-clicked="deleteExpense(expense)">
            <lux-icon-base width="25" height="25" icon-name="Delete Expense Line Item" icon-color="red">
              <lux-icon-denied></lux-icon-denied>
            </lux-icon-base>
          </input-button>
          <input type="hidden" name="travel_request[estimates][][id]" :value="expense.id"/>
        </grid-item>
        <grid-item vertical="center" columns="lg-2 sm-12">
          <input-select label="Expense Type" name="travel_request[estimates][][cost_type]"
              :id="'travel_request_estimates_cost_type_' + expense.id"
              :value="expense.cost_type" width="expand"
              @change="updateExpenseType($event, expense)"
              :options="cost_types" required hideLabel></input-select>
        </grid-item>
        <grid-item vertical="center" columns="lg-1 sm-12">
          <input-text label="Occurrences" name="travel_request[estimates][][recurrence]"
              :id="'travel_request_estimates_recurrence_' + expense.id"
              @input="updateRecurrence($event, expense)"
              :value="expense.recurrence" width="expand" required hideLabel></input-text>
        </grid-item>
        <grid-item vertical="center" columns="lg-2 sm-12">
          <input-text label="Cost per Occurrence" name="travel_request[estimates][][amount]"
              :id="'travel_request_estimates_amount_' + expense.id"
              @input="updateAmount($event, expense)"
              :value="expense.amount" width="expand"
              :readonly="isAmountReadonly(expense)" required hideLabel></input-text>
        </grid-item>
        <grid-item vertical="center" columns="lg-4 sm-12">
          <input-text label="Note" name="travel_request[estimates][][description]"
              :id="'travel_request_estimates_description_' + expense.id"
              :value="expense.description" width="expand" hideLabel></input-text>
        </grid-item>
        <grid-item vertical="center" columns="lg-2 sm-12" class="expense-total-col">
          <input-text label="Total" name="travel_request[estimates][][total]"
              :id="'travel_request_estimates_total_' + expense.id"
              :value="setLineItemTotal(expense)" width="expand" disabled hideLabel></input-text>
        </grid-item>
      </grid-container>
    </grid-item>

    <grid-item columns="lg-11 sm-12" class="expense-add">
      <input-button type="button" id="add-expense-button" variation="text"
        @button-clicked="addExpense()">
        <lux-icon-base width="16" height="16" icon-name="Add Expense">
          <lux-icon-add></lux-icon-add>
        </lux-icon-base> Add Expense</input-button>
    </grid-item>

    <grid-item columns="lg-12 sm-12">
      <hr>
    </grid-item>

    <grid-item columns="lg-10 sm-12 auto" class="expense-total" :offset="true">
      <text-style variation="strong">Total:</text-style>
    </grid-item>
    <grid-item columns="lg-2 sm-12" class="expense-total">
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
     default: () => [{ id: null, cost_type: null, recurrence: null, amount: null, description: '', other_id: 'id_0' }]
    },
    cost_types: {
     type: Array,
     default: []
    },
  },
  methods: {
    addExpense() {
      this.expenseData.push({ id: null, cost_type: null, recurrence: null, amount: null, description: '', other_id: 'id_'+this.expenseData.length })
    },
    deleteExpense(expense) {
      let foundIndex = this.expenseData.findIndex(x => x.other_id == expense.other_id)
      this.expenseData.splice(foundIndex, 1)
    },
    isAmountReadonly(expense){
      return (expense.cost_type === 'personal_auto') ? true : false
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
    updateExpenseType(inputVal, expense) {
      let foundIndex = this.find_expense(expense)
      this.expenseData[foundIndex].cost_type = inputVal
      if(inputVal === 'personal_auto'){
        this.expenseData[foundIndex].amount = 0.58
      } else {
        this.expenseData[foundIndex].amount = null
      }
    },
    updateRecurrence(inputVal, expense) {
      let foundIndex = this.find_expense(expense)
      expense.recurrence = inputVal
      this.expenseData[foundIndex] = expense
    },
    updateAmount(inputVal, expense) {
      let foundIndex = this.find_expense(expense)
      expense.amount = inputVal
      this.expenseData[foundIndex] = expense
    },
    find_expense(expense){
      let foundIndex = 0
      if (expense.id !== null){
        foundIndex = this.expenseData.findIndex(x => x.id == expense.id)
      }else {
        foundIndex = this.expenseData.findIndex(x => x.other_id == expense.other_id)
      }
      return foundIndex
    },
    normalizeAmount(amount) {
      return Number(amount).toFixed(2)
    }
  },
}
</script>

<style scoped>

</style>
