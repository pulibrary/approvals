import { mount } from "@vue/test-utils";
import TravelEstimateForm from "../components/travelEstimateForm.vue";

let wrapper;
describe("travelEstimateForm.vue", () => {
    beforeEach(() => {

        wrapper = mount(TravelEstimateForm, {
            propsData: {
                expenses: [
                    {"id":1,"cost_type":"registration","amount":"50.0","recurrence":2,"description":"","other_id":"id_1"},
                    {"id":2,"cost_type":"meals","amount":"193.0","recurrence":1,"description":"Foo!","other_id":"id_2"}
                ],
                cost_types: [
                    {label: 'ground transportation', value: 'ground_transportation'},
                    {label: 'lodging (per night)', value: 'lodging'},
                    {label: 'meals and related expenses (daily)', value: 'meals'},
                    {label: 'miscellaneous', value: 'misc'},{label: 'registration fee', value: 'registration'},
                    {label: 'car rental', value: 'rental_vehicle'},
                    {label: 'airfare', value: 'air'},{label: 'taxi', value: 'taxi'},
                    {label: 'mileage - personal car', value: 'personal_auto'},
                    {label: 'other transit', value: 'transit_other'},
                    {label: 'train', value: 'train'}
                ]
            },
            stubs: [
                "lux-input-text",
                "input-select",
                "input-button",
                "lux-icon-denied",
                "lux-icon-add",
                "lux-icon-base",
                "grid-container",
                "grid-item",
                "text-style",
            ]
        });
    });

    it("has the proper number of expense line items", () => {
        expect(wrapper.vm.expenseData.length).toBe(2);
    });

    it("calculates the line item expense correctly", () => {
        expect(wrapper.vm.setLineItemTotal(wrapper.vm.expenseData[0])).toBe('100.00');
    });

    it("calculates the total expenses correctly", () => {
        expect(wrapper.vm.expensesTotal()).toBe('293.00');
    });

    it("adds an expense line", () => {
        wrapper.vm.addExpense();
        expect(wrapper.vm.expenseData.length).toBe(3);
    });

    it("deletes the appropriate expense line", () => {
        wrapper.vm.deleteExpense(wrapper.vm.expenseData[0]);
        expect(wrapper.vm.expenseData.length).toBe(1);
        const emptyArray = wrapper.vm.expenseData.filter(expense => {
            return expense.other_id === "id_1";
        });
        expect(emptyArray.length).toBe(0);
    });

});
