import { createPinia } from 'pinia';
import { createApp } from 'vue';

import App from './App.vue';
import { initializeApp } from './app/init';
import { router } from './app/router';
import './style.css';

const app = createApp(App);

app.use(createPinia());
app.use(router);

initializeApp();

app.mount('#app');
