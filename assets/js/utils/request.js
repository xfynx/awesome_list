import axios from 'axios'

// create an axios instance
const service = axios.create({
    baseURL: "/api",
    timeout: 60 * 1000 // request timeout
})

// request interceptor
service.interceptors.request.use(
    config => {
        return config
    },
    error => {
        // do something with request error
        return Promise.reject(error)
    }
)

// response interceptor
service.interceptors.response.use(
    /**
     * If you want to get http information such as headers or status
     * Please return  response => response
     */

    /**
     * Determine the request status by custom code
     * Here is just an example
     * You can also judge the status by HTTP Status Code
     */
    response => {
        const res = response
        if (res.status !== 200) {
            return Promise.reject(new Error(res || 'Error'))
        } else {
            return res
        }
    },
    error => {
        console.log('err' + error) // for debug

        return Promise.reject(error)
    }
)

export default service
