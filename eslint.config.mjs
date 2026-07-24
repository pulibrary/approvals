import js from "@eslint/js";
import pluginVue from 'eslint-plugin-vue';

const rec = js.configs.recommended;

export default [
    ...pluginVue.configs['flat/recommended'],
    { languageOptions: { ecmaVersion: "latest", sourceType: "module" }, files: ["**/*.{js,mjs}"], rules: {...rec.rules, "no-undef": "off" } },
    { languageOptions: { ecmaVersion: 2020, sourceType: "module", globals: { describe: true, it: false, expect: true } }, files: ["**/*.{spec,test}.js"] },
];
