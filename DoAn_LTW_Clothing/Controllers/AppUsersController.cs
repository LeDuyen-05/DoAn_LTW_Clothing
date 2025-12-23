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
    public class AppUsersController : Controller
    {
        private ClothingShopEntities db = new ClothingShopEntities();

        // GET: AppUsers
        public ActionResult Index()
        {
            return View(db.AppUsers.ToList());
        }
        public ActionResult DangKy()
        {
            return View();
        }
        public ActionResult DangNhap()
        {
            return View();
        }
        public ActionResult DangNhapAdmin()
        {
            return View();
        }
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult DangKy(AppUser user, string ConfirmPassword)
        {
            if (ModelState.IsValid)
            {
                var checkEmail = db.AppUsers.FirstOrDefault(s => s.Email == user.Email);
                if (checkEmail != null)
                {
                    ViewBag.Error = "Email này đã được sử dụng. Vui lòng chọn Email khác.";
                    return View();
                }
                if (user.PasswordHash != ConfirmPassword)
                {
                    ViewBag.Error = "Mật khẩu nhập lại không khớp.";
                    return View();
                }
                user.CreatedAt = DateTime.Now; 
                user.IsActive = true; 
                user.Role = "Customer"; 
                db.AppUsers.Add(user);
                db.SaveChanges();
                ViewBag.ThongBao = "Đăng ký thành công! Vui lòng đăng nhập.";
                return RedirectToAction("DangNhap");
            }

            return View();
        }
        [HttpPost]
        public ActionResult DangNhap(string email, string password)
        {
            if (ModelState.IsValid)
            {
                var user = db.AppUsers.FirstOrDefault(s => s.Email == email && s.PasswordHash == password);

                if (user != null)
                {
                    Session["TaiKhoan"] = user;
                    Session["HoTen"] = user.FullName;
                    return RedirectToAction("Index", "Home");
                }
                else
                {
                    ViewBag.ThongBao = "Tên đăng nhập hoặc mật khẩu không đúng!";
                }
            }
            return View();

        }
        [HttpPost]
        public ActionResult DangNhapAdmin(string email, string password)
        {
            if (ModelState.IsValid)
            {
                var user = db.AppUsers.FirstOrDefault(s => s.Email == email && s.PasswordHash == password);

                if (user != null && user.Role == "Admin")
                {
                    Session["Admin"] = user;
                    return RedirectToAction("Index", "admin");
                }
                else
                {
                    ViewBag.ThongBao = "Tên đăng nhập hoặc mật khẩu không đúng!";
                }
            }
            return View();

        }
        public ActionResult LogOff()
        {
            // Xóa Session
            Session["User"] = null;
            Session["HoTen"] = null;
            Session["Cart"] = null; // Xóa giỏ hàng khi đăng xuất (tùy chọn)

            // Quay về trang chủ
            return RedirectToAction("Index", "Home");
        }
        // GET: AppUsers/Details/5
        public ActionResult Details(int? id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            AppUser appUser = db.AppUsers.Find(id);
            if (appUser == null)
            {
                return HttpNotFound();
            }
            return View(appUser);
        }

        // GET: AppUsers/Create
        public ActionResult Create()
        {
            return View();
        }

        // POST: AppUsers/Create
        // To protect from overposting attacks, enable the specific properties you want to bind to, for 
        // more details see https://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create([Bind(Include = "UserId,Email,PasswordHash,FullName,Phone,Role,IsActive,CreatedAt")] AppUser appUser)
        {
            if (ModelState.IsValid)
            {
                db.AppUsers.Add(appUser);
                db.SaveChanges();
                return RedirectToAction("Index");
            }

            return View(appUser);
        }

        // GET: AppUsers/Edit/5
        public ActionResult Edit(int? id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            AppUser appUser = db.AppUsers.Find(id);
            if (appUser == null)
            {
                return HttpNotFound();
            }
            return View(appUser);
        }

        // POST: AppUsers/Edit/5
        // To protect from overposting attacks, enable the specific properties you want to bind to, for 
        // more details see https://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit([Bind(Include = "UserId,Email,PasswordHash,FullName,Phone,Role,IsActive,CreatedAt")] AppUser appUser)
        {
            if (ModelState.IsValid)
            {
                db.Entry(appUser).State = EntityState.Modified;
                db.SaveChanges();
                return RedirectToAction("Index");
            }
            return View(appUser);
        }

        // GET: AppUsers/Delete/5
        public ActionResult Delete(int? id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            AppUser appUser = db.AppUsers.Find(id);
            if (appUser == null)
            {
                return HttpNotFound();
            }
            return View(appUser);
        }

        // POST: AppUsers/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public ActionResult DeleteConfirmed(int id)
        {
            AppUser appUser = db.AppUsers.Find(id);
            db.AppUsers.Remove(appUser);
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
