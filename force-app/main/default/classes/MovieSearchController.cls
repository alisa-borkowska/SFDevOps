public with sharing class MovieSearchController {
    private static String apiKey = '521677eae959c7a466ff4dc1bdb08f6e';

    public static String tmdbRequest(String endpoint, String queryParams) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();

        String url = 'https://api.themoviedb.org/3/';
        url += endpoint;
        url += '?api_key=' + apiKey;
        url += '&' + queryParams;

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
    public static String findActors(String query){
        return tmdbRequest('search/person', 'query='+query+'&page=1');
    }
}