<template>
  <div class="container">
    <h1 class="title">Awesome List</h1>
    <div class="columns">
      <div class="column">
        <div class="control has-icons-left">
          <div class="select">
            <select v-model="currentLang" @change="selectList()">
              <option v-for="item in languages" :key="item.id" :value="item">{{ item.name }}</option>
            </select>
          </div>
          <div class="icon is-small is-left">
            💾
          </div>
        </div>
      </div>
      <div class="column">
        <div class="control has-icons-left">
          <div class="select">
            <select v-model="minStars" @change="selectList()" :disabled="currentLang === {}">
              <option>0</option>
              <option>50</option>
              <option>100</option>
              <option>200</option>
              <option>500</option>
              <option>1000</option>
            </select>
          </div>
          <div class="icon is-small is-left">
            🌟
          </div>
        </div>
      </div>
    </div>
    <div class="content" v-if="categoriesWithLibs !== {}">
      <h1>Оглавление</h1>
      <div v-for="(list, category) in categoriesWithLibs">
        <h3><a :href="`#${category}`">{{category}}</a></h3>
      </div>
    </div>
    <div class="content" v-if="categoriesWithLibs !== {}">
      <h1>По категориям</h1>
      <div v-for="(list, category) in categoriesWithLibs">
        <h3><a :name="category">🔗</a> {{category}}</h3>
        <ul>
          <li v-for="library in list">
            <a :href="library.url">{{ library.name }}</a> 🌟{{ library.stars_count }} 📅{{ countDays(library.last_commit_at) }}  - {{ library.description }}
          </li>
        </ul>
        <br>
      </div>
    </div>
  </div>
</template>

<script>
import {getAllLanguages, getAllCategories} from "../api/awesome-lists"

export default {
  name: 'AwesomeList',
  components: {},
  filters: {},
  data() {
    return {
      languages: [],
      currentLang: {},
      categoriesWithLibs: {},
      minStars: 0
    }
  },
  computed: {},
  created() {
    this.getLanguages()
  },
  methods: {
    getLanguages() {
      getAllLanguages().then(response => {
        this.languages = response.data.data
      })
    },
    selectList() {
      console.log(this.currentLang)
      getAllCategories({id: this.currentLang.id, min_stars: this.minStars}).then(response => {
        console.log(response.data.data)
        this.categoriesWithLibs = response.data.data
      })
    },
    countDays(lastCommitAt) {
      const date = Date.parse(lastCommitAt)
      const today = new Date()
      return Math.round((today - date) / (1000 * 3600 * 24))
    }
  }
}
</script>