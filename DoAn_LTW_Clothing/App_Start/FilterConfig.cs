using System.Web;
using System.Web.Mvc;

namespace DoAn_LTW_Clothing
{
    public class FilterConfig
    {
        public static void RegisterGlobalFilters(GlobalFilterCollection filters)
        {
            filters.Add(new HandleErrorAttribute());
        }
    }
}
