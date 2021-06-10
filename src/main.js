import Vue from 'vue'
import App from './App.vue'
import {
    Button,
    Input,
    Switch,
    Form,
    FormItem,
    RadioGroup,
    Radio,
    Message
} from 'element-ui';
import 'element-ui/lib/theme-chalk/index.css'
Vue.use(Button);
Vue.use(Input);
Vue.use(Switch);
Vue.use(Form);
Vue.use(FormItem);
Vue.use(RadioGroup);
Vue.use(Radio);


Vue.prototype.$message = Message;
Vue.config.productionTip = false

new Vue({
    render: h => h(App),
}).$mount('#app')