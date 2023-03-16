public class ProductController {
    @AuraEnabled(cacheable=true)
    public static Produc2 getSingleProduct() {
        return [
            SELECT Id, DisplayUrl
            FROM Product2
            LIMIT 1
        ];
    }
}