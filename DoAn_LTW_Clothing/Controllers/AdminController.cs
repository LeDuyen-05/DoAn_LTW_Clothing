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
       
        // GET: Admin
        // Khởi tạo đối tượng kết nối CSDL (Entity Framework)
        private ClothingShopEntities db = new ClothingShopEntities();

        // GET: Admin
        public ActionResult Index(DateTime? fromDate, DateTime? toDate)
        {
            // Mặc định nếu không chọn ngày thì lấy trong 30 ngày gần nhất
            var start = fromDate ?? DateTime.Now.AddDays(-30);
            var end = toDate ?? DateTime.Now;

            // 1. Thống kê tổng số (ViewBag)
            ViewBag.TotalRevenue = db.Orders
                .Where(o => o.Status == "Delivered" && o.CreatedAt >= start && o.CreatedAt <= end)
                .Sum(o => (decimal?)o.TotalAmount) ?? 0;

            ViewBag.NewOrdersCount = db.Orders.Count(o => o.Status == "New");

            // 2. Dữ liệu cho biểu đồ (Nhóm theo ngày)
            var chartData = db.Orders
                .Where(o => o.Status == "Delivered" && o.CreatedAt >= start && o.CreatedAt <= end)
                .GroupBy(o => DbFunctions.TruncateTime(o.CreatedAt))
                .Select(g => new {
                    Date = g.Key,
                    Revenue = g.Sum(x => x.TotalAmount)
                })
                .OrderBy(x => x.Date)
                .ToList();

            ViewBag.ChartLabels = chartData.Select(x => x.Date.Value.ToString("dd/MM")).ToArray();
            ViewBag.ChartValues = chartData.Select(x => x.Revenue).ToArray();

            // 3. Danh sách đơn hàng bên dưới
            var orders = db.Orders.OrderByDescending(o => o.CreatedAt).ToList();
            return View(orders);
        }

        // POST: Cập nhật trạng thái đơn hàng
        [HttpPost]
        public ActionResult UpdateStatus(int orderId, string status)
        {
            // Tìm đơn hàng theo ID
            var order = db.Orders.Find(orderId);

            if (order != null)
            {
                // Cập nhật trạng thái mới
                order.Status = status;
                // Cập nhật thời gian chỉnh sửa cuối cùng
                order.UpdatedAt = DateTime.Now;

                // Lưu thay đổi vào SQL Server
                db.SaveChanges();
            }

            // Sau khi cập nhật xong, quay lại trang Index để thấy thay đổi
            return RedirectToAction("Index");
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