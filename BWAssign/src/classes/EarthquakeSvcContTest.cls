/*
 * Test class for EarthquakeSvcCont apex controller class.
 */
@istest
private class EarthquakeSvcContTest 
{
    /*
     * Test the controller constructor
     */
    private static testmethod void testMinimumRequiredForPackaging()
    {
        EarthquakeSvcCont esc = new EarthquakeSvcCont();
        esc.search();

        esc.selectedCity = '';

        EarthquakeSvcCont.Earthquake e = new EarthquakeSvcCont.Earthquake();
    }
}