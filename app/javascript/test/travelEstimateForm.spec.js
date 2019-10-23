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
          {"id":484,"cost_type":"registration","amount":"50.0","recurrence":1,"description":""},
          {"id":363,"cost_type":"meals","amount":"193.0","recurrence":2,"description":"Foo!"}
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
      stubs: ["input-text", "input-select", "input-button", "lux-icon-denied", "lux-icon-refresh", "lux-icon-base", "grid-container", "grid-item"]
    })
  })

  it("has the proper number of expense line items", () => {
    expect(wrapper.vm.expenseData.length).toBe(2)
  })

})
