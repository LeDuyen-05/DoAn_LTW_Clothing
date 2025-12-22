using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace DoAn_LTW_Clothing.Models
{
    public class HomeVM
    {
        // Danh sách để hiển thị lên Banner
        public List<Category> BannerCategories { get; set; }

        // Danh sách sản phẩm mới (dùng cho phần New Arrivals bên dưới)
        public List<Product> NewArrivals { get; set; }
        // 3. Danh sách Bán chạy (Best Sellers)
        public List<Product> BestSellers { get; set; }
        public Product DealProduct { get; set; }
    }
}