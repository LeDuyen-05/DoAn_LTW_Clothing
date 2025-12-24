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

        // LẤY HOẶC TẠO CART
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


        // XEM GIỎ HÀNG
        public ActionResult Index()
        {
            int cartId = GetOrCreateCartId();

            var items = db.CartItems
                          .Include(c => c.Product)
                          .Where(c => c.CartId == cartId)
                          .ToList();

            return View(items);
        }

        // THÊM VÀO GIỎ
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

        // XÓA SẢN PHẨM
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

        // CẬP NHẬT SỐ LƯỢNG
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
        [ValidateAntiForgeryToken]
        public ActionResult CheckOut(string FullName, string Phone, string Address, string Note, string PaymentMethod)
        {
            if (Session["UserId"] == null)
                return RedirectToAction("DangNhap", "AppUsers");

            int? cartId = Session["CartId"] as int?;
            if (cartId == null)
                return RedirectToAction("Index");

            var cartItems = db.CartItems
                              .Include(c => c.Product)
                              .Where(c => c.CartId == cartId)
                              .ToList();

            if (!cartItems.Any())
                return RedirectToAction("Index");

            // KIỂM TRA TỒN KHO
            foreach (var item in cartItems)
            {
                var variant = db.ProductVariants
                                .FirstOrDefault(v => v.ProductId == item.ProductId && (v.Size + " - " + v.Color) == item.Note);
                var stock = db.ProductVariantStocks.Find(variant?.VariantId);
                if (stock == null || stock.Stock < item.Quantity)
                {
                    TempData["ErrorMessage"] = $"Sản phẩm {item.Product.ProductName} ({item.Note}) không đủ tồn kho!";
                    return RedirectToAction("Index");
                }
            }

            // Tạo Order
            var order = new Order
            {
                UserId = (int)Session["UserId"],
                CustomerName = FullName,
                Phone = Phone,
                AddressLine = Address,
                Note = Note,
                Status = PaymentMethod == "Online" ? "Paid" : "New", // Online thanh toán trực tuyến, COD để New
                TotalAmount = cartItems.Sum(c => c.UnitPrice * c.Quantity),
                CreatedAt = DateTime.Now,
                UpdatedAt = DateTime.Now
            };
            db.Orders.Add(order);
            db.SaveChanges();

            // Tạo OrderItem và trừ kho
            foreach (var item in cartItems)
            {
                db.OrderItems.Add(new OrderItem
                {
                    OrderId = order.OrderId,
                    ProductId = item.ProductId,
                    ProductName = item.Product.ProductName,
                    Quantity = item.Quantity,
                    UnitPrice = item.UnitPrice,
                    Note = item.Note
                });

                var variant = db.ProductVariants.FirstOrDefault(v => v.ProductId == item.ProductId && (v.Size + " - " + v.Color) == item.Note);
                if (variant != null)
                {
                    var stock = db.ProductVariantStocks.Find(variant.VariantId);
                    if (stock != null)
                    {
                        stock.Stock -= item.Quantity;
                        if (stock.Stock < 0) stock.Stock = 0;
                    }
                }
            }

            db.SaveChanges();

            // Nếu thanh toán Online, tạo Payment và chuyển sang trang Payment
            if (PaymentMethod == "Online")
            {
                var payment = new Payment
                {
                    OrderId = order.OrderId,
                    PaymentMethod = "Ví điện tử", // hoặc "Chuyển khoản", tùy chọn bạn gửi từ form
                    Amount = order.TotalAmount,
                    Status = "Paid",
                    PaymentDate = DateTime.Now
                };
                db.Payments.Add(payment);
                db.SaveChanges();

                // Xóa giỏ hàng
                db.CartItems.RemoveRange(cartItems);
                var cart = db.Carts.Find(cartId);
                if (cart != null) db.Carts.Remove(cart);
                db.SaveChanges();
                Session.Remove("CartId");

                return RedirectToAction("Payment", new { orderId = order.OrderId });
            }
            else // COD
            {
                db.CartItems.RemoveRange(cartItems);
                var cart = db.Carts.Find(cartId);
                if (cart != null) db.Carts.Remove(cart);
                db.SaveChanges();
                Session.Remove("CartId");

                return RedirectToAction("Success");
            }
        }


        public ActionResult Payment(int orderId)
        {
            var order = db.Orders.Include(o => o.OrderItems.Select(oi => oi.Product))
                                 .FirstOrDefault(o => o.OrderId == orderId);
            if (order == null) return HttpNotFound();

            var payment = db.Payments.FirstOrDefault(p => p.OrderId == orderId);
            if (payment == null) return HttpNotFound();

            ViewBag.PaymentMethod = payment.PaymentMethod;
            ViewBag.OrderCode = order.OrderId; // hoặc order.OrderCode nếu có
            ViewBag.TotalAmount = order.TotalAmount;

            return View(order.OrderItems.ToList());
        }

        public ActionResult Success()
        {
            return View();
        }
    }
}
