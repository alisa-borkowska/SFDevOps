public with sharing class Currency_Converter {
    @AuraEnabled
    public static List<Map<String, String>> getCurrencies() {
        List<String> currencies = new List<String>();
        currencies.add('EUR');
        String url = 'https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml';
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        req.setEndpoint(url);
        req.setMethod('GET');
        HttpResponse res = http.send(req);

        Dom.Document doc = res.getBodyDocument();
        Dom.XmlNode root = doc.getRootElement();
        List<Dom.XMLNode> cube1 = root.getChildElements();
        List<Dom.XmlNode> cube2 = cube1[2].getChildElements();
        List<Dom.XmlNode> cube3 = cube2[0].getChildElements();
        for (Dom.XmlNode node : cube3) {
            currencies.add(node.getAttributeValue('currency', null));
        }
        List<Map<String, String>> currenciesOptions = new List<Map<String, String>>();
        for (String cur : currencies) {
            currenciesOptions.add(new Map<String, String>{'label'=>cur, 'value'=>cur});
        }
        return currenciesOptions;
    }

    @AuraEnabled
    public static Decimal calculateCurr(String fromCurrency, String toCurrency, String amount) {
        Map<String, Decimal> rates = new Map<String, Decimal>();
        Decimal result = 0.0;
        String url = 'https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml';
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        req.setEndpoint(url);
        req.setMethod('GET');
        HttpResponse res = http.send(req);

        Dom.Document doc = res.getBodyDocument();
        Dom.XmlNode root = doc.getRootElement();
        List<Dom.XMLNode> cube1 = root.getChildElements();
        List<Dom.XmlNode> cube2 = cube1[2].getChildElements();
        List<Dom.XmlNode> cube3 = cube2[0].getChildElements();
        for (Dom.XmlNode node : cube3) {
            rates.put(node.getAttributeValue('currency', null), Decimal.valueOf(node.getAttributeValue('rate', null)));
        }
        rates.put('EUR', 1.0);

        if (fromCurrency.equals('EUR')) {
            result = (Decimal.valueOf(amount) * rates.get(toCurrency)) / 1.0;
        } else if (toCurrency.equals('EUR')) {
            result = (Decimal.valueOf(amount) * 1.0) / rates.get(fromCurrency);
        } else if (fromCurrency.equals(toCurrency)) {
            result = Decimal.valueOf(amount);
        } else {
            result = (Decimal.valueOf(amount) * rates.get(toCurrency)) / rates.get(fromCurrency);
        }
        return result.setScale(2);
    }


}