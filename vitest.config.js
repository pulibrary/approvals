import { defineConfig } from 'vitest/config';
import vue from '@vitejs/plugin-vue'; 

export default defineConfig({
  test: {
    include: ['app/javascript/test/*.spec.js'],
    globals: true,
    environment: 'jsdom',
  },
  plugins: [vue()],
})
