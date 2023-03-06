public with sharing class MovieFinderController {
    private static String apiKey = '521677eae959c7a466ff4dc1bdb08f6e';

    public static String tmdbRequest(String endpoint, String queryParams) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();

        String url = 'https://api.themoviedb.org/3/';
        url += endpoint;
        url += '?api_key=' + apiKey;
        url += '&language=en-US&' + queryParams;

        req.setEndpoint(url);
        req.setMethod('GET');
        
        HttpResponse res = h.send(req);
        return res.getBody();
    }
    
    @AuraEnabled(cacheable=true)
    public static String findMovies(String query){
        return tmdbRequest('search/movie', 'query='+query+'&page=1');
    }

    @AuraEnabled(cacheable=true)
    public static string findPopularMovies(Integer page){
        return tmdbRequest('movie/popular', 'page='+page);
    }
    
    @AuraEnabled(cacheable=true)
    public static String findActors(String query){
        return tmdbRequest('search/person', 'query='+query+'&page=1');
    }

    @AuraEnabled(cacheable=true)
    public static string findPopularActors(Integer page){        
        return tmdbRequest('person/popular', 'page='+page);
    }

    @AuraEnabled(cacheable=true)
    public static string detailsView(String selectedMovieId){
        return tmdbRequest('movie/'+selectedMovieId, '');
    }

    @AuraEnabled(cacheable=true)
    public static string getGenresList(){
        return tmdbRequest('genre/movie/list','');
    }
    @AuraEnabled(cacheable=true)
    public static string discover(String params){
        return tmdbRequest('discover/movie', params);
    }

    @AuraEnabled (cacheable=true)
    public static string getActorsList(String selectedMovieId){
        return tmdbRequest('movie/'+selectedMovieId+'/credits', '');
    }

    @AuraEnabled (cacheable=true)
    public static string actorDetailsView(String selectedActorId){
        return tmdbRequest('person/'+selectedActorId, '');
    }

    @AuraEnabled
    public static void addComment(String comment, String autor, String movieId, Integer rating){
        Comment__c com = new Comment__c(Text__c=comment, Autor__c=autor, MovieId__c=movieId, Rating__c=rating, Date_Of_Comment__c=Datetime.now());
        insert com;
    }

    @AuraEnabled(cacheable=true)
    public static List<Comment__c> getComments(String movieId){
        Comment__c[] dane = [SELECT Text__c, Autor__c, Rating__c, Date_Of_Comment__c FROM Comment__c WHERE MovieId__c = :movieId];
        System.debug(dane);
        return dane;
    }

}