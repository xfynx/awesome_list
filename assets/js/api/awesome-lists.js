import request from '../utils/request'

export function getAllLanguages() {
    console.log("trigger langs")
    return request({
        url: '/languages',
        method: 'get'
    })
}

export function getAllCategories(query) {
    console.log("trigger cats and libs")
    return request({
        url: '/categories_with_libs',
        method: 'get',
        params: query
    })
}
