using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Web.Mvc;
using DoAn_LTW_Clothing.Models;

namespace DoAn_LTW_Clothing.Controllers
{
    public class ShoppingCartController : Controller
    {
        ClothingShopEntities db = new ClothingShopEntities();

        // ================== LẤY HOẶC TẠO CART ==================
        private int GetOrCreateCartId()
        {
            if (Session["CartId"] != null)
                return (int)Session["CartId"];

            var cart = new Cart
            {
                CartToken = Guid.NewGuid().ToString("N"), 
                UserId = null 
            };

            db.Carts.Add(cart);
            db.SaveChanges();

            Session["CartId"] = cart.CartId;
            return cart.CartId;
        }


        // ================== XEM GIỎ HÀNG ==================
        public ActionResult Index()
        {
            int cartId = GetOrCreateCartId();

            var items = db.CartItems
                          .Include(c => c.Product)
                          .Where(c => c.CartId == cartId)
                          .ToList();

            return View(items);
        }

        // ================== THÊM VÀO GIỎ ==================
        [HttpPost]
        public ActionResult AddToCart(int variantId, int quantity)
        {
            var variant = db.ProductVariants
                            .Include(v => v.Product)
                            .FirstOrDefault(v => v.VariantId == variantId);

            if (variant == null)
                return HttpNotFound();

            int cartId = GetOrCreateCartId();
            string note = variant.Size + " - " + variant.Color;

            var cartItem = db.CartItems.FirstOrDefault(c =>
                c.CartId == cartId &&
                c.ProductId == variant.ProductId &&
                c.Note == note);

            if (cartItem != null)
            {
                cartItem.Quantity += quantity;
            }
            else
            {
                db.CartItems.Add(new CartItem
                {
                    CartId = cartId,
                    ProductId = variant.ProductId,
                    Quantity = quantity,
                    UnitPrice = variant.Price,
                    Note = note,
                    CreatedAt = DateTime.Now
                });
            }

            db.SaveChanges();
            return RedirectToAction("Index");
        }

        // ================== XÓA 1 SẢN PHẨM ==================
        public ActionResult Remove(int id)
        {
            var item = db.CartItems.Find(id);
            if (item != null)
            {
                db.CartItems.Remove(item);
                db.SaveChanges();
            }
            return RedirectToAction("Index");
        }

        // ================== CẬP NHẬT SỐ LƯỢNG ==================
        [HttpPost]
        public ActionResult Update(int id, int quantity)
        {
            var item = db.CartItems.Find(id);
            if (item != null && quantity > 0)
            {
                item.Quantity = quantity;
                db.SaveChanges();
            }
            return RedirectToAction("Index");
        }

        public ActionResult CheckOut()
        {
            // 🔐 CHƯA ĐĂNG NHẬP
            if (Session["UserId"] == null)
            {
                // Lưu lại URL hiện tại để login xong quay về
                Session["ReturnUrl"] = Url.Action("CheckOut", "ShoppingCart");
                return RedirectToAction("Login", "Account");
            }

            int? cartId = Session["CartId"] as int?;
            if (cartId == null)
                return RedirectToAction("Index");

            var items = db.CartItems
                .Include(c => c.Product)
                .Where(c => c.CartId == cartId)
                .ToList();

            if (!items.Any())
                return RedirectToAction("Index");

            return View(items);
        }

        [HttpPost]
        public ActionResult CheckOut(string FullName, string Phone, string Address, string Note)
        {
            if (Session["UserId"] == null)
                return RedirectToAction("DangNhap", "AppUsers");

            int? cartId = Session["CartId"] as int?;
            if (cartId == null)
                return RedirectToAction("Index");

            // TODO: Lưu Order (nâng cao)
            var cartItems = db.CartItems.Where(c => c.CartId == cartId).ToList();
            db.CartItems.RemoveRange(cartItems);

            var cart = db.Carts.Find(cartId);
            if (cart != null)
                db.Carts.Remove(cart);

            db.SaveChanges();
            Session.Remove("CartId");

            return RedirectToAction("Success");
        }

        // =========================
        // SUCCESS
        // =========================
        public ActionResult Success()
        {
            return View();
        }
    }
}
