<template>
  <lux-grid-container class="expenses">
    <lux-grid-item
      columns="lg-12 sm-12"
      class="expense-row-header"
    >
      <lux-grid-container>
        <lux-grid-item
          vertical="center"
          columns="lg-1 sm-12"
          class="expense-delete"
        >
          <lux-text-style>Delete</lux-text-style>
        </lux-grid-item>
        <lux-grid-item
          vertical="center"
          columns="lg-2 sm-12"
        >
          <lux-text-style id="expense-type-column">
            Expense Type
          </lux-text-style>
        </lux-grid-item>
        <lux-grid-item
          vertical="center"
          columns="lg-1 sm-12"
        >
          <lux-text-style>Occurrences</lux-text-style>
        </lux-grid-item>
        <lux-grid-item
          vertical="center"
          columns="lg-2 sm-12"
        >
          <lux-text-style>Cost per Occurrence</lux-text-style>
        </lux-grid-item>
        <lux-grid-item
          vertical="center"
          columns="lg-4 sm-12"
        >
          <lux-text-style>Note</lux-text-style>
        </lux-grid-item>
        <lux-grid-item
          vertical="center"
          columns="lg-2 sm-12"
        >
          <lux-text-style>Total</lux-text-style>
        </lux-grid-item>
      </lux-grid-container>
    </lux-grid-item>

    <lux-grid-item
      v-for="expense in expenseData"
      :key="expense.id"
      columns="lg-12 sm-12"
      class="expense-row"
    >
      <lux-grid-container>
        <lux-grid-item
          vertical="center"
          columns="lg-1 sm-12"
          class="expense-delete"
        >
          <lux-input-button
            class="button-delete-row"
            type="button"
            variation="text"
            @button-clicked="deleteExpense(expense)"
          >
            <lux-icon-base
              width="25"
              height="25"
              icon-name="Delete Expense Line Item"
              icon-color="red"
            >
              <lux-icon-denied />
            </lux-icon-base>
          </lux-input-button>
          <input
            type="hidden"
            name="travel_request[estimates][][id]"
            :value="expense.id"
          >
        </lux-grid-item>
        <lux-grid-item
          vertical="center"
          columns="lg-2 sm-12"
        >
          <lux-input-select
            :id="'travel_request_estimates_cost_type_' + expense.id"
            :ref="'expense_type'"
            label="Expense Type"
            name="travel_request[estimates][][cost_type]"
            :value="expense.cost_type"
            width="expand"
            :options="cost_types"
            required
            hide-label
            @change="updateExpenseType($event, expense)"
          />
        </lux-grid-item>
        <lux-grid-item
          vertical="center"
          columns="lg-1 sm-12"
        >
          <lux-input-text
            :id="'travel_request_estimates_recurrence_' + expense.id"
            label="Occurrences"
            name="travel_request[estimates][][recurrence]"
            placeholder="1"
            :value="expense.recurrence"
            width="expand"
            required
            hide-label
            @input="updateRecurrence($event, expense)"
          />
        </lux-grid-item>
        <lux-grid-item
          vertical="center"
          columns="lg-2 sm-12"
        >
          <lux-input-text
            :id="'travel_request_estimates_amount_' + expense.id"
            label="Cost per Occurrence"
            name="travel_request[estimates][][amount]"
            :value="expense.amount"
            width="expand"
            :readonly="isAmountReadonly(expense)"
            placeholder="$ 0.00"
            required
            hide-label
            @input="updateAmount($event, expense)"
          />
        </lux-grid-item>
        <lux-grid-item
          vertical="center"
          columns="lg-4 sm-12"
        >
          <lux-input-text
            :id="'travel_request_estimates_description_' + expense.id"
            label="Note"
            name="travel_request[estimates][][description]"
            :value="expense.description"
            width="expand"
            hide-label
          />
        </lux-grid-item>
        <lux-grid-item
          vertical="center"
          columns="lg-2 sm-12"
          class="expense-total-col"
        >
          <lux-input-text
            :id="'travel_request_estimates_total_' + expense.id"
            label="Total"
            name="travel_request[estimates][][total]"
            :value="setLineItemTotal(expense)"
            width="expand"
            disabled
            hide-label
          />
        </lux-grid-item>
      </lux-grid-container>
    </lux-grid-item>

    <lux-grid-item
      columns="lg-11 sm-12"
      class="expense-add"
    >
      <lux-input-button
        id="add-expense-button"
        type="button"
        variation="text"
        @button-clicked="addExpense()"
      >
        <lux-icon-base
          width="16"
          height="16"
          icon-name="Add Expense"
        >
          <lux-icon-add />
        </lux-icon-base> Add Expense
      </lux-input-button>
    </lux-grid-item>

    <lux-grid-item columns="lg-12 sm-12">
      <hr>
    </lux-grid-item>

    <lux-grid-item
      columns="lg-10 sm-12 auto"
      class="expense-total"
      :offset="true"
    >
      <lux-text-style variation="strong">
        Total:
      </lux-text-style>
    </lux-grid-item>
    <lux-grid-item
      columns="lg-2 sm-12"
      class="expense-total"
    >
      <lux-text-style
        id="expenses-total"
        variation="strong"
      >
        ${{ expensesTotal() }}
      </lux-text-style>
    </lux-grid-item>
  </lux-grid-container>
</template>

<script>
/* eslint-disable vue/prop-name-casing, vue/require-valid-default-prop */
export default {
    name: "TravelEstimateForm",
    props: {
        expenses: {
            type: Array,
            default: () => [{ id: null, cost_type: null, recurrence: '1', amount: null, description: '', other_id: 'id_0' }]
        },
        cost_types: {
            type: Array,
            default: []
        },
    },
    data: function () {
        return {
            expenseData: this.expenses,
        };
    },
    methods: {
        addExpense() {
            this.expenseData.push({
                id: null,
                cost_type: null,
                recurrence: '1',
                amount: null,
                description: '',
                other_id: 'id_'+this.expenseData.length
            });
            this.$nextTick(() => {
                const index = this.expenseData.length - 1;
                this.$refs?.expense_type?.[index]?.focusSelect();
            });
        },
        deleteExpense(expense) {
            const foundIndex = this.expenseData.findIndex(x => x.other_id == expense.other_id);
            this.expenseData.splice(foundIndex, 1);
        },
        isAmountReadonly(expense) {
            return (expense.cost_type === 'personal_auto') ? true : false;
        },
        setLineItemTotal(expense) {
            return (expense.amount * expense.recurrence).toFixed(2);
        },
        expensesTotal() {
            let total = 0;
            const len = this.expenseData.length;
            for (let i = 0; i < len; i++) {
                total = total + (this.expenseData[i].amount * this.expenseData[i].recurrence);
            }
            return total.toFixed(2);
        },
        updateExpenseType(inputVal, expense) {
            const foundIndex = this.find_expense(expense);
            this.expenseData[foundIndex].cost_type = inputVal;
            if(inputVal === 'personal_auto'){
                this.expenseData[foundIndex].amount = .655;
            } else {
                this.expenseData[foundIndex].amount = null;
            }
        },
        updateRecurrence(inputVal, expense) {
            const foundIndex = this.find_expense(expense);
            expense.recurrence = inputVal;
            this.expenseData[foundIndex] = expense;
        },
        updateAmount(inputVal, expense) {
            const foundIndex = this.find_expense(expense);
            expense.amount = inputVal;
            this.expenseData[foundIndex] = expense;
        },
        find_expense(expense){
            let foundIndex = 0;
            if (expense.id !== null){
                foundIndex = this.expenseData.findIndex(x => x.id == expense.id);
            }else {
                foundIndex = this.expenseData.findIndex(x => x.other_id == expense.other_id);
            }
            return foundIndex;
        },
        normalizeAmount(amount) {
            return Number(amount).toFixed(2);
        }
    },
};
</script>

<style scoped>

</style>
