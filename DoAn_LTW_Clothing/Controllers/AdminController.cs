using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace DoAn_LTW_Clothing.Controllers
{
    public class AdminController : Controller
    {
        // GET: Admin
        public ActionResult Index()
        {
            return View();
        }

        public ActionResult GetCategorys()
        {
            return View();
        }
        public ActionResult CreateCategorys()
        {
            return View();
        }
    }
}