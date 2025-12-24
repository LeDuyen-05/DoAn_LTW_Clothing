using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Mvc;
using DoAn_LTW_Clothing.Models;

namespace DoAn_LTW_Clothing.Controllers
{
    public class AdminController : Controller
    {
        private ClothingShopEntities db = new ClothingShopEntities();
        // GET: Admin
        public ActionResult Index()
        {
            var data = new HomeAdmin()
            {
                totalCategory = db.Categories.Count(),
                totalOrder = db.Orders.Count(),
                totalProduct = db.Products.Count(),
                totalApuser = db.AppUsers.Count(),
            };
            return View(data);
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