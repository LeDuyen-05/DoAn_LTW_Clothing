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
    public class ProductsController : Controller
    {
        private ClothingShopEntities db = new ClothingShopEntities();

        // GET: Products
        public ActionResult Index(int? id, string kw, string khoanggia)
        {
            // 1. Dùng Include để load kèm bảng biến thể (để lấy giá)
            var products = db.Products.Include("ProductVariants").AsQueryable();

            // 2. Lọc theo Danh mục (nếu có id)
            if (id.HasValue)
            {
                products = products.Where(p => p.CategoryId == id.Value);
            }

            // 3. Lọc theo Từ khóa (nếu có kw)
            if (!string.IsNullOrEmpty(kw))
            {
                products = products.Where(p => p.ProductName.Contains(kw));
            }

            // 4. Lọc theo Khoảng giá (Sửa logic lấy từ bảng ProductVariant)
            if (!string.IsNullOrEmpty(khoanggia))
            {
                if (khoanggia == "-") // Trường hợp chọn "Tất cả"
                {
                    // Không làm gì cả
                }
                else
                {
                    var minmax = khoanggia.Split('-');
                    if (minmax.Length == 2)
                    {
                        // Xử lý Giá thấp nhất (Min)
                        if (decimal.TryParse(minmax[0], out decimal min))
                        {
                            // Logic: Lấy sản phẩm có ít nhất 1 biến thể có giá >= min
                            products = products.Where(p => p.ProductVariants.Any(v => v.Price >= min));
                        }

                        // Xử lý Giá cao nhất (Max)
                        if (decimal.TryParse(minmax[1], out decimal max))
                        {
                            // Logic: Lấy sản phẩm có ít nhất 1 biến thể có giá <= max
                            products = products.Where(p => p.ProductVariants.Any(v => v.Price <= max));
                        }
                    }
                }
            }

            // Trả về View
            return View(products.OrderByDescending(p => p.ProductName).ToList());
        }
        public ActionResult DanhMuc()
        {
            var catagories = db.CategoryGroups.ToList();
            return PartialView(catagories);
        }

        // GET: Product/Details/5
        public ActionResult Details(int id)
        {
            // 1. Lấy thông tin sản phẩm hiện tại (Code cũ của bạn)
            var product = db.Products.Include("Category")
                                     .Include("ProductVariants")
                                     .Include("ProductImages") // Nhớ Include bảng ảnh phụ nếu có
                                     .FirstOrDefault(x => x.ProductId == id);

            if (product == null)
            {
                return HttpNotFound();
            }

            // 2. LOGIC SẢN PHẨM LIÊN QUAN (Viết tại đây)
            // Lấy 4 sản phẩm cùng danh mục nhưng khác ID sản phẩm hiện tại
            var relatedProducts = db.Products
                                    .Where(x => x.CategoryId == product.CategoryId && x.ProductId != id)
                                    .OrderByDescending(x => x.CreatedAt) // Lấy sản phẩm mới nhất (hoặc dùng Guid.NewGuid() để random)
                                    .Take(4)
                                    .ToList();

            // 3. Truyền dữ liệu sang View bằng ViewBag
            ViewBag.RelatedProducts = relatedProducts;

            return View(product);
        }
        // GET: Products/Create
        public ActionResult Create()
        {
            ViewBag.CategoryId = new SelectList(db.Categories, "CategoryId", "CatSlug");
            return View();
        }

        // POST: Products/Create
        // To protect from overposting attacks, enable the specific properties you want to bind to, for 
        // more details see https://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create([Bind(Include = "ProductId,CategoryId,ProductName,Slug,Material,MainImage,Summary,IsActive,CreatedAt,UpdatedAt")] Product product)
        {
            if (ModelState.IsValid)
            {
                db.Products.Add(product);
                db.SaveChanges();
                return RedirectToAction("Index");
            }

            ViewBag.CategoryId = new SelectList(db.Categories, "CategoryId", "CatSlug", product.CategoryId);
            return View(product);
        }

        // GET: Products/Edit/5
        public ActionResult Edit(int? id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            Product product = db.Products.Find(id);
            if (product == null)
            {
                return HttpNotFound();
            }
            ViewBag.CategoryId = new SelectList(db.Categories, "CategoryId", "CatSlug", product.CategoryId);
            return View(product);
        }

        // POST: Products/Edit/5
        // To protect from overposting attacks, enable the specific properties you want to bind to, for 
        // more details see https://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit([Bind(Include = "ProductId,CategoryId,ProductName,Slug,Material,MainImage,Summary,IsActive,CreatedAt,UpdatedAt")] Product product)
        {
            if (ModelState.IsValid)
            {
                db.Entry(product).State = EntityState.Modified;
                db.SaveChanges();
                return RedirectToAction("Index");
            }
            ViewBag.CategoryId = new SelectList(db.Categories, "CategoryId", "CatSlug", product.CategoryId);
            return View(product);
        }

        // GET: Products/Delete/5
        public ActionResult Delete(int? id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            Product product = db.Products.Find(id);
            if (product == null)
            {
                return HttpNotFound();
            }
            return View(product);
        }

        // POST: Products/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public ActionResult DeleteConfirmed(int id)
        {
            Product product = db.Products.Find(id);
            db.Products.Remove(product);
            db.SaveChanges();
            return RedirectToAction("Index");
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                db.Dispose();
            }
            base.Dispose(disposing);
        }
    }
}
