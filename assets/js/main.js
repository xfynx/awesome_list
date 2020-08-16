import Vue from 'vue';
import AwesomeList from './views/awesome-list.vue'
import { library } from '@fortawesome/fontawesome-svg-core'
import { faUserSecret } from '@fortawesome/free-solid-svg-icons'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'

library.add(faUserSecret)
Vue.component('font-awesome-icon', FontAwesomeIcon)

require('../css/app.scss');

Vue.config.productionTip = process.env.NODE_ENV === 'production';

new Vue({
  render: h => h(AwesomeList),
}).$mount('#app')
