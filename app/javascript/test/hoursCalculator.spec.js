import { mount } from "@vue/test-utils";
import HoursCalculator from "../components/hoursCalculator.vue";

let wrapper;
describe("HoursCalculator.vue", () => {
    beforeEach(() => {

        wrapper = mount(HoursCalculator, {
            propsData: {
                hoursPerDay: 8,
                holidays: ['2019-12-25','2019-12-26','2019-09-11','2020-12-25']
            },
            global: {
                stubs: {
                    "lux-input-text": true,
                    "lux-date-picker": true,
                    "lux-grid-item": true
                }
            }
        });
    });

    it("has the right hoursPerDay", () => {
        expect(wrapper.vm.hoursPerDay).toBe(8);
    });

    it("pads the value 1", () => {
        expect(wrapper.vm.pad('1',2)).toBe('01');
    });

    it("does not pad the value 12", () => {
        expect(wrapper.vm.pad('12',2)).toBe('12');
    });

    it("updates the total hours requested caption/hint", () => {
        wrapper.vm.setHours('2/23/2020 - 2/25/2020');
        expect(wrapper.vm.helperCaption).toBe('16 hours = 2.00 days (1 holiday and weekend dates excluded.)');
        wrapper.vm.updateCaption('24');
        expect(wrapper.vm.helperCaption).toBe('24 hours = 3.00 days (1 holiday and weekend dates excluded.)');
    });

    it("knows a holiday", () => {
        expect(wrapper.vm.isHoliday(new Date('2019-12-25'))).toBe(true);
    });

    it("knows a non holiday", () => {
        expect(wrapper.vm.isHoliday(new Date('2019-11-25'))).toBe(false);
    });

    it("knows a workday", () => {
        expect(wrapper.vm.isWorkday(new Date('2019-12-23'))).not.toBeUndefined();
        expect(wrapper.vm.nonWorkDays).toBe(0);
    });

    it("knows a non workday", () => {
        expect(wrapper.vm.isWorkday(new Date('2019-9-21'))).toBeUndefined();
        expect(wrapper.vm.nonWorkDays).toBe(1);
    });

    it("knows a holiday is not a workday", () => {
        expect(wrapper.vm.isWorkday(new Date('2019-12-25'))).toBeUndefined();
        expect(wrapper.vm.nonWorkDays).toBe(1);
    });

    it("calculates the total hours", () => {
        expect(wrapper.vm.calculateTotalHours('2019-12-23 - 2019-12-27')).toBe(24);
    });

});
