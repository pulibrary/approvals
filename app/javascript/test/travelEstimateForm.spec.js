import { createLocalVue, mount, shallowMount } from "@vue/test-utils"
import TravelEstimateForm from "../components/travelEstimateForm.vue"

const localVue = createLocalVue()
let wrapper
describe("travelEstimateForm.vue", () => {
  beforeEach(() => {

    wrapper = mount(TravelEstimateForm, {
      localVue,
      propsData: {
        expenses: [
          {"id":1,"cost_type":"registration","amount":"50.0","recurrence":2,"description":""},
          {"id":2,"cost_type":"meals","amount":"193.0","recurrence":1,"description":"Foo!"}
        ],
        cost_types: [
          {label: 'Ground transportation', value: 'ground_transportation'},
          {label: 'Lodging', value: 'lodging'},{label: 'Meals', value: 'meals'},
          {label: 'Misc', value: 'misc'},{label: 'Registration', value: 'registration'},
          {label: 'Rental vehicle', value: 'rental_vehicle'},
          {label: 'Air', value: 'air'},{label: 'Taxi', value: 'taxi'},
          {label: 'Personal auto', value: 'personal_auto'},
          {label: 'Transit other', value: 'transit_other'},
          {label: 'Train', value: 'train'}
        ]
      },
      stubs: [
        "input-text",
        "input-select",
        "input-button",
        "lux-icon-denied",
        "lux-icon-refresh",
        "lux-icon-base",
        "grid-container",
        "grid-item",
        "text-style",
      ]
    })
  })

  it("has the proper number of expense line items", () => {
    expect(wrapper.vm.expenseData.length).toBe(2)
  })

  it("calculates the line item expense correctly", () => {
    expect(wrapper.vm.setLineItemTotal(wrapper.vm.expenseData[0])).toBe('100.00')
  })

  it("calculates the total expenses correctly", () => {
    expect(wrapper.vm.expensesTotal()).toBe('293.00')
  })

  it("adds an expense line", () => {
    wrapper.vm.addExpense()
    expect(wrapper.vm.expenseData.length).toBe(3)
  })

  it("deletes the appropriate expense line", () => {
    let id = wrapper.vm.expenseData[0].id
    wrapper.vm.deleteExpense(wrapper.vm.expenseData[0])
    expect(wrapper.vm.expenseData.length).toBe(1)
    let emptyArray = wrapper.vm.expenseData.filter(expense => {
      return expense.id === 1
    })
    expect(emptyArray.length).toBe(0)
  })

})
