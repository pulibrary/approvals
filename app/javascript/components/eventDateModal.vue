<template>
  <transition name="eventDateModal">
    <div
      v-if="showModal"
      class="modal-mask"
    >
      <div class="modal-wrapper">
        <div class="modal-container">
          <div class="modal-header">
            <h4>Possible Date Detected</h4>
          </div>
          <div class="modal-body">
            <slot name="body">
              default body
            </slot>
          </div>
          <div class="modal-footer">
            <lux-input-button
              type="button"
              variation="solid"
              size="small"
              @button-clicked="submit"
            >
              Continue
            </lux-input-button>
            <lux-input-button
              type="button"
              variation="outline"
              size="small"
              @button-clicked="$emit('closeModal')"
            >
              Go Back
            </lux-input-button>
          </div>
        </div>
      </div>
    </div>
  </transition>
</template>

<script>
/* eslint-disable vue/require-default-prop, vue/require-prop-type-constructor */
export default {
    name: "EventDateModal",
    props: {
        showModal: false
    },
    emits: ['closeModal'],
    data: function(){
        return {};
    },
    methods: {
        submit() {
            document.querySelector(".travel-form").submit();
        }
    }
};
</script>

<style scoped>
  .modal-mask {
    position: fixed;
    z-index: 9998;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0, 0, 0, 0.5);
    display: table;
    transition: opacity 0.3s ease;
  }

  .modal-wrapper {
    display: table-cell;
    vertical-align: middle;
  }

  .modal-container {
    width: 400px;
    margin: 0px auto;
    padding: 20px 30px;
    background-color: #fff;
    border-radius: 2px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.33);
    transition: all 0.3s ease;
    font-family: Helvetica, Arial, sans-serif;
  }

  .modal-body {
    margin: 20px 0;
  }

  .modal-enter {
    opacity: 0;
  }

  .modal-leave-active {
    opacity: 0;
  }

  .modal-enter .modal-container,
  .modal-leave-active .modal-container {
    -webkit-transform: scale(1.1);
    transform: scale(1.1);
  }
</style>
