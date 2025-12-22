using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using DoAn_LTW_Clothing.Models;

namespace DoAn_LTW_Clothing.Controllers
{
    public class HomeController : Controller
    {
        private ClothingShopEntities db = new ClothingShopEntities();

        // GET: Home/Index
        public ActionResult Index()
        {
            HomeVM model = new HomeVM();

            // 1. Lấy Banner (3 danh mục đầu)
            model.BannerCategories = db.Categories.Take(3).ToList();

            // 2. Lấy New Arrivals 
            // QUAN TRỌNG: Phải dùng .Include để lấy dữ liệu bảng Category và CategoryGroup thì bên View mới lọc được
            model.NewArrivals = db.Products
                                .Include("Category.CategoryGroup") // Nạp Category và Group để lọc (Men/Women/...)
                                .Include("ProductVariants")        // Nạp biến thể để lấy Giá tiền
                                .OrderByDescending(p => p.ProductId) // Sắp xếp mới nhất
                                .Take(10)
                                .ToList();

            // 3. Lấy Best Sellers (Ngẫu nhiên 10 cái)
            model.BestSellers = db.Products
                                .Include("ProductVariants") // Cần nạp giá tiền để hiển thị
                                .OrderBy(p => Guid.NewGuid())
                                .Take(10)
                                .ToList();

            // 4. Lấy Deal of the Week (Ngẫu nhiên 1 cái)
            model.DealProduct = db.Products
                                .Include("ProductVariants") // Cần giá tiền
                                .OrderBy(x => Guid.NewGuid())
                                .FirstOrDefault();

            return View(model);
        }
        // Chức năng Đăng ký nhận tin (Newsletter)
        [HttpPost]
        public ActionResult Subscribe(string email)
        {
            TempData["SubscribeMsg"] = "Cảm ơn bạn đã đăng ký: " + email;
            return RedirectToAction("Index");
        }
        public ActionResult Contact()
        {
           
            return View();
        }
    }
}