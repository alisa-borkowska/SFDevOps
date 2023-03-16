import { LightningElement, wire } from 'lwc';
import getGenresList from '@salesforce/apex/MovieFinderController.getGenresList';
import discover from '@salesforce/apex/MovieFinderController.discover';
import { MessageContext, publish } from 'lightning/messageService';
import MFMC from '@salesforce/messageChannel/MovieFinderMessageChannel__c';

/**
 * @typedef {Object} Movie zwracane przez search/movie
 * @prop {boolean} adult dla doroslych?
 * @prop {string} backdrop_path link do obrazka tla
 * @prop {number[]} genre_ids id gatunkow (inty)
 * @prop {number} id int
 * @prop {string} original_language jezyk oryginalu
 * @prop {string} original_title tytul (w oryginalnym jezyku)
 * @prop {string} overview krotki opis filmu
 * @prop {number} popularity popularnosc (float)
 * @prop {string} poster_path link do plakatu
 * @prop {string} release_date data w formacie YYYY-MM-DD
 * @prop {string} title tytul filmu (w wybranym jezyku)
 * @prop {boolean} video idk, czy zawiera trailer?
 * @prop {number} video_average float
 * @prop {number} vote_count int
 */

/** 
 * @typedef {Object} Genre zwracane przez get/genres
 * @prop {number} id int
 * @prop {string} name nazwa
 */

export default class DetailSearch extends LightningElement {
    genres = [];

    paramStrings = {
        genre: {value: '', label: ''},
        year: '',
        region: '',
    }

    @wire(MessageContext)
    messageContext;

    @wire(getGenresList)
    genresList({ data, error }) {
        if (data) {
            console.log(data);
            /** @type {Genre[]} */
            this.genres = Object.assign([], JSON.parse(data).genres).map(genre => ({ value: genre.id, label: genre.name }));

        } else if (error) {
            console.log(error)
        }
    }

    onGenre(e) {
        this.paramStrings.genre = this.genres.find(g=>g.value==e.detail.value)??{value:'',label:''};
        this.template.querySelector('lightning-combobox').value = this.paramStrings.genre.value;
        console.log(this.paramStrings.genre.label)
        this.searchMovies();
    }

    onCountry(e) {
        this.paramStrings.region = e.detail.value;
    }

    onYear(e) {
        this.paramStrings.year = e.detail.value;
    }

    searchMovies() {
        console.log(this.paramStrings);
        if (this.paramStrings.genre.value || this.paramStrings.year || this.paramStrings.region) {
            publish(this.messageContext, MFMC, {
                queryType: 'discover',
                query: `with_genres=${this.paramStrings.genre.value}&` +
                    `year=${this.paramStrings.year}&` +
                    `region=${this.paramStrings.region}`
            })
        }
    }

}