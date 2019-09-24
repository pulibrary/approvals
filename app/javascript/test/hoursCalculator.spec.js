import { createLocalVue, mount, shallowMount } from "@vue/test-utils"
import HoursCalculator from "../components/hoursCalculator.vue"

const localVue = createLocalVue()
let wrapper
describe("HoursCalculator.vue", () => {
  beforeEach(() => {

    wrapper = mount(HoursCalculator, {
      localVue,
      propsData: {
        hoursPerDay: 8,
        holidays: ['2019-12-25','2019-12-26','2019-09-11']
      },
      stubs: ["input-text", "date-picker", "grid-item"]
    })
  })

  it("has the right hoursPerDay", () => {
    expect(wrapper.vm.hoursPerDay).toBe(8)
  })

  it("pads the value 1", () => {
    expect(wrapper.vm.pad('1',2)).toBe('01')
  })

  it("does not pad the value 12", () => {
    expect(wrapper.vm.pad('12',2)).toBe('12')
  })

  it("knows a holiday", () => {
    expect(wrapper.vm.isHoliday(new Date('2019-12-25'))).toBe(true)
  })

  it("knows a non holiday", () => {
    expect(wrapper.vm.isHoliday(new Date('2019-11-25'))).toBe(false)
  })

  it("knows a workday", () => {
    expect(wrapper.vm.isWorkday(new Date('2019-12-23'))).not.toBeUndefined()
  })

  it("knows a non workday", () => {
    expect(wrapper.vm.isWorkday(new Date('2019-9-21'))).toBeUndefined()
  })

  it("knows a holiday is not a workday", () => {
    expect(wrapper.vm.isWorkday(new Date('2019-12-25'))).toBeUndefined()
  })

  it("calculates the total hours", () => {
    expect(wrapper.vm.calculateTotalHours('2019-12-23 - 2019-12-27')).toBe(24)
  })

})
