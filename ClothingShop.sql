/* =========================================================
   – SHOP QUẦN ÁO ONLINE (FULL DB WITH FOREIGN KEYS)
   ========================================================= */

-- 1. KHỞI TẠO DB (RESET NẾU ĐÃ CÓ)
USE master;
GO

IF DB_ID('ClothingShop') IS NOT NULL
BEGIN
    ALTER DATABASE ClothingShop SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE ClothingShop;
END;
GO

CREATE DATABASE ClothingShop COLLATE SQL_Latin1_General_CP1_CI_AS;
GO

USE ClothingShop;
GO

/* =========================================================
   2. TẠO BẢNG & RÀNG BUỘC (TABLES & CONSTRAINTS)
   ========================================================= */

-- [1] Bảng AppUser
CREATE TABLE [dbo].[AppUser](
    [UserId] INT IDENTITY(1,1) NOT NULL,
    [Email] VARCHAR(120) NOT NULL UNIQUE,
    [PasswordHash] VARCHAR(256) NOT NULL,
    [FullName] NVARCHAR(120) NULL,
    [Phone] VARCHAR(20) NULL,
    [Role] VARCHAR(20) NOT NULL DEFAULT 'Customer', 
    [IsActive] BIT NOT NULL DEFAULT 1,
    [CreatedAt] DATETIME2(0) DEFAULT GETDATE(),
    PRIMARY KEY CLUSTERED ([UserId])
);
GO

-- [2] Bảng CategoryGroup
CREATE TABLE [dbo].[CategoryGroup](
    [GroupId] INT IDENTITY(1,1) NOT NULL,
    [GroupCode] VARCHAR(40) NOT NULL,
    [GroupName] NVARCHAR(120) NOT NULL,
    [SortOrder] INT NOT NULL DEFAULT 0,
    [IsActive] BIT NOT NULL DEFAULT 1,
    [CreatedAt] DATETIME2(0) DEFAULT GETDATE(),
    PRIMARY KEY CLUSTERED ([GroupId])
);
GO

-- [3] Bảng Category
CREATE TABLE [dbo].[Category](
    [CategoryId] INT IDENTITY(1,1) NOT NULL,
    [GroupId] INT NOT NULL,
    [CatSlug] VARCHAR(60) NOT NULL,
    [CatName] NVARCHAR(120) NOT NULL,
    [Description] NVARCHAR(300) NULL,
    [SortOrder] INT NOT NULL DEFAULT 0,
    [IsActive] BIT NOT NULL DEFAULT 1,
    [CreatedAt] DATETIME2(0) DEFAULT GETDATE(),
    PRIMARY KEY CLUSTERED ([CategoryId]),
    CONSTRAINT [FK_Category_CategoryGroup] 
        FOREIGN KEY([GroupId]) REFERENCES [dbo].[CategoryGroup]([GroupId])
);
GO

/* =========================================================
   PRODUCT + VARIANT + STOCK 
   ========================================================= */

-- [4] Bảng Product
CREATE TABLE [dbo].[Product](
    [ProductId] INT IDENTITY(1,1) NOT NULL,
    [CategoryId] INT NOT NULL,
    [ProductName] NVARCHAR(180) NOT NULL,
    [Slug] VARCHAR(90) NOT NULL,
    [Material] NVARCHAR(100) NULL,
    [MainImage] NVARCHAR(250) NOT NULL,
    [Summary] NVARCHAR(300) NULL,
    [IsActive] BIT NOT NULL DEFAULT 1,
    [CreatedAt] DATETIME2(0) DEFAULT GETDATE(),
    [UpdatedAt] DATETIME2(0) DEFAULT GETDATE(),
    PRIMARY KEY CLUSTERED ([ProductId]),
    CONSTRAINT FK_Product_Category FOREIGN KEY ([CategoryId]) 
        REFERENCES Category([CategoryId])
);

-- BỔ SUNG: ProductVariant
CREATE TABLE [dbo].[ProductVariant](
    [VariantId] INT IDENTITY(1,1) NOT NULL,
    [ProductId] INT NOT NULL,
    [SKU] VARCHAR(50) NOT NULL UNIQUE,
    [Size] VARCHAR(20) NULL,
    [Color] NVARCHAR(50) NULL,
    [Price] DECIMAL(12,0) NOT NULL,
    [IsActive] BIT NOT NULL DEFAULT 1,
    PRIMARY KEY (VariantId),
    FOREIGN KEY (ProductId) REFERENCES Product(ProductId) ON DELETE CASCADE
);

-- BỔ SUNG: ProductVariantStock
CREATE TABLE [dbo].[ProductVariantStock](
    [VariantId] INT PRIMARY KEY,
    [Stock] INT NOT NULL DEFAULT 0,
    FOREIGN KEY (VariantId) REFERENCES ProductVariant(VariantId) ON DELETE CASCADE
);

-- Bảng ProductImage
CREATE TABLE [dbo].[ProductImage](
    [ImageId] INT IDENTITY(1,1) NOT NULL,
    [ProductId] INT NOT NULL,
    [ImageUrl] NVARCHAR(260) NOT NULL,
    PRIMARY KEY CLUSTERED ([ImageId]),
    CONSTRAINT FK_ProductImage_Product 
        FOREIGN KEY([ProductId]) REFERENCES Product([ProductId]) ON DELETE CASCADE
);
GO

-- [6] Bảng ProductReview
CREATE TABLE [dbo].[ProductReview](
    [ReviewId] INT IDENTITY(1,1) NOT NULL,
    [ProductId] INT NOT NULL,
    [UserId] INT NOT NULL,
    [Rating] INT NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    [Comment] NVARCHAR(500) NULL,
    [CreatedAt] DATETIME2(0) DEFAULT GETDATE(),
    PRIMARY KEY CLUSTERED ([ReviewId]),
    CONSTRAINT FK_Review_Product FOREIGN KEY([ProductId]) REFERENCES Product([ProductId]) ON DELETE CASCADE,
    CONSTRAINT FK_Review_User FOREIGN KEY([UserId]) REFERENCES AppUser([UserId])
);
GO

-- [7] Bảng Wishlist
CREATE TABLE [dbo].[Wishlist](
    [WishlistId] INT IDENTITY(1,1) NOT NULL,
    [UserId] INT NOT NULL,
    [ProductId] INT NOT NULL,
    [CreatedAt] DATETIME2(0) DEFAULT GETDATE(),
    PRIMARY KEY CLUSTERED ([WishlistId]),
    CONSTRAINT FK_Wishlist_User FOREIGN KEY([UserId]) REFERENCES AppUser([UserId]) ON DELETE CASCADE,
    CONSTRAINT FK_Wishlist_Product FOREIGN KEY([ProductId]) REFERENCES Product([ProductId])
);
GO

-- [8] Bảng Voucher
CREATE TABLE [dbo].[Voucher](
    [VoucherId] INT IDENTITY(1,1) NOT NULL,
    [Code] VARCHAR(20) NOT NULL UNIQUE, 
    [DiscountType] VARCHAR(10) NOT NULL,
    [DiscountValue] DECIMAL(12,0) NOT NULL,
    [MinOrderValue] DECIMAL(12,0) DEFAULT 0,
    [StartDate] DATETIME2(0) NOT NULL,
    [EndDate] DATETIME2(0) NOT NULL,
    [UsageLimit] INT DEFAULT 100,
    [IsActive] BIT DEFAULT 1,
    PRIMARY KEY CLUSTERED ([VoucherId])
);
GO

-- [9] Bảng CustomerAddress
CREATE TABLE [dbo].[CustomerAddress](
    [AddressId] INT IDENTITY(1,1) NOT NULL,
    [UserId] INT NOT NULL,
    [Line1] NVARCHAR(200) NOT NULL,
    [Ward] NVARCHAR(100) NULL,
    [District] NVARCHAR(100) NULL,
    [Province] NVARCHAR(100) NULL,
    [Note] NVARCHAR(200) NULL,
    [CreatedAt] DATETIME2(0) DEFAULT GETDATE(),
    PRIMARY KEY CLUSTERED ([AddressId]),
    CONSTRAINT FK_Address_User FOREIGN KEY([UserId]) REFERENCES AppUser([UserId]) ON DELETE CASCADE
);
GO

-- [10] Bảng Order
CREATE TABLE [dbo].[Order](
    [OrderId] INT IDENTITY(1,1) NOT NULL,
    [UserId] INT NULL,
    [VoucherId] INT NULL,
    [CustomerName] NVARCHAR(120) NOT NULL,
    [Phone] VARCHAR(20) NOT NULL,
    [AddressLine] NVARCHAR(220) NULL,
    [Note] NVARCHAR(240) NULL,
    [Status] VARCHAR(20) NOT NULL DEFAULT 'New',
    [TotalAmount] DECIMAL(12,0) NOT NULL,
    [CreatedAt] DATETIME2(0) DEFAULT GETDATE(),
    [UpdatedAt] DATETIME2(0) DEFAULT GETDATE(),
    PRIMARY KEY CLUSTERED ([OrderId]),
    CONSTRAINT FK_Order_AppUser FOREIGN KEY([UserId]) REFERENCES AppUser([UserId]),
    CONSTRAINT FK_Order_Voucher FOREIGN KEY([VoucherId]) REFERENCES Voucher([VoucherId])
);
GO

-- [11] Bảng OrderItem
CREATE TABLE [dbo].[OrderItem](
    [OrderItemId] INT IDENTITY(1,1) NOT NULL,
    [OrderId] INT NOT NULL,
    [ProductId] INT NOT NULL,
    [ProductName] NVARCHAR(180) NOT NULL,
    [Quantity] INT NOT NULL,
    [UnitPrice] DECIMAL(12,0) NOT NULL,
    [Note] NVARCHAR(200) NULL,
    PRIMARY KEY CLUSTERED ([OrderItemId]),
    CONSTRAINT FK_OrderItem_Order FOREIGN KEY([OrderId]) REFERENCES [Order]([OrderId]) ON DELETE CASCADE,
    CONSTRAINT FK_OrderItem_Product FOREIGN KEY([ProductId]) REFERENCES [Product]([ProductId])
);
GO

-- [12] Bảng Payment
CREATE TABLE [dbo].[Payment](
    [PaymentId] INT IDENTITY(1,1) NOT NULL,
    [OrderId] INT NOT NULL,
    [PaymentMethod] VARCHAR(50) NOT NULL,
    [TransactionId] VARCHAR(100) NULL, 
    [Amount] DECIMAL(12, 0) NOT NULL,
    [Status] VARCHAR(20) NOT NULL,
    [PaymentDate] DATETIME2(0) DEFAULT GETDATE(),
    PRIMARY KEY CLUSTERED ([PaymentId]),
    CONSTRAINT FK_Payment_Order FOREIGN KEY([OrderId]) REFERENCES [Order]([OrderId]) ON DELETE CASCADE
);
GO

-- [13] Bảng Cart
CREATE TABLE [dbo].[Cart](
    [CartId] INT IDENTITY(1,1) NOT NULL,
    [CartToken] VARCHAR(64) NOT NULL,
    [UserId] INT NULL,
    [CreatedAt] DATETIME2(0) DEFAULT GETDATE(),
    [UpdatedAt] DATETIME2(0) DEFAULT GETDATE(),
    PRIMARY KEY CLUSTERED ([CartId]),
    CONSTRAINT FK_Cart_User FOREIGN KEY([UserId]) REFERENCES AppUser([UserId]) ON DELETE CASCADE
);
GO

-- [14] Bảng CartItem
CREATE TABLE [dbo].[CartItem](
    [CartItemId] INT IDENTITY(1,1) NOT NULL,
    [CartId] INT NOT NULL,
    [ProductId] INT NOT NULL,
    [Quantity] INT NOT NULL,
    [UnitPrice] DECIMAL(12, 0) NOT NULL,
    [Note] NVARCHAR(200) NULL,
    [CreatedAt] DATETIME2(0) DEFAULT GETDATE(),
    PRIMARY KEY CLUSTERED ([CartItemId]),
    CONSTRAINT FK_CartItem_Cart FOREIGN KEY([CartId]) REFERENCES Cart([CartId]) ON DELETE CASCADE,
    CONSTRAINT FK_CartItem_Product FOREIGN KEY([ProductId]) REFERENCES Product([ProductId])
);
GO
-- 3. THÊM DỮ LIỆU MẪU (SEED DATA) - BẢN FULL FINAL (ĐÃ FIX DANH MỤC & THÊM PHỤ KIỆN)

-- A. Users (Người dùng)
SET IDENTITY_INSERT [dbo].[AppUser] ON;
INSERT [dbo].[AppUser] ([UserId], [Email], [PasswordHash], [FullName], [Phone], [Role], [IsActive], [CreatedAt]) 
VALUES 
(1, N'admin@clothing.vn', N'hashed_admin_123', N'Quản Trị Viên', N'0999888777', 'Admin', 1, GETDATE()),
(2, N'khach01@gmail.com', N'hashed_user_123', N'Nguyễn Văn A', N'0901234567', 'Customer', 1, GETDATE());
SET IDENTITY_INSERT [dbo].[AppUser] OFF;
GO

-- B. Category Groups (Nhóm danh mục)
SET IDENTITY_INSERT [dbo].[CategoryGroup] ON;
INSERT [dbo].[CategoryGroup] ([GroupId], [GroupCode], [GroupName], [SortOrder], [IsActive]) VALUES 
(1, N'men', N'Thời trang Nam', 1, 1),
(2, N'women', N'Thời trang Nữ', 2, 1),
(3, N'kids', N'Thời trang Trẻ em', 3, 1),
(4, N'accessories', N'Phụ kiện', 4, 1);
SET IDENTITY_INSERT [dbo].[CategoryGroup] OFF;
GO

-- C. Categories (Danh mục con - Đã sắp xếp chuẩn)
SET IDENTITY_INSERT [dbo].[Category] ON;
INSERT INTO [dbo].[Category] ([CategoryId], [GroupId], [CatSlug], [CatName], [Description], [SortOrder], [IsActive]) VALUES
-- Nhóm Nam (Group 1)
(1, 1, 'men-shirt', N'Áo Thun', N'Áo phông, Polo nam', 1, 1),
(2, 1, 'men-pants', N'Quần Dài', 'Jean, Kaki', 2, 1),
(3, 1, 'men-jacket', N'Áo Khoác', NULL, 3, 1),
-- Nhóm Nữ (Group 2)
(4, 2, 'women-dress', N'Váy Đầm', N'Váy công sở, dự tiệc', 1, 1),
(5, 2, 'women-top', 'Áo Kiểu', NULL, 2, 1),
(6, 2, 'women-jeans', N'Quần Jean', NULL, 3, 1),
-- Nhóm Trẻ Em (Group 3)
(7, 3, 'kids-shirt', N'Áo Trẻ Em', NULL, 1, 1),
(8, 3, 'kids-pants', N'Quần Trẻ Em', NULL, 2, 1),
-- Nhóm Phụ Kiện (Group 4)
(9, 4, 'hats', N'Mũ Nón', NULL, 1, 1),
(10, 4, 'bags', N'Túi Xách', NULL, 2, 1),
(11, 4, 'belt', N'Thắt Lưng', NULL, 3, 1),
(12, 4, 'socks', N'Tất/Vớ', NULL, 4, 1);
SET IDENTITY_INSERT [dbo].[Category] OFF;
GO

-- D. Products (Sản phẩm - Đã kiểm tra kỹ ID Danh mục)
SET IDENTITY_INSERT [dbo].[Product] ON;

INSERT INTO [dbo].[Product]
([ProductId], [CategoryId], [ProductName], [Slug], [Material], [MainImage], [Summary])
VALUES
-- === NAM (Category 1, 2, 3) ===
(1, 1, N'Áo Thun Basic Trắng', 'ao-thun-basic-trang', N'100% Cotton', 'tshirt_w.jpg', N'Áo Thun Thoáng Mát Vải Hiệu Ứng Loang The Weekend 027 Trắng'),
(2, 1, N'Áo Polo Nam Đen', 'ao-polo-nam-den', N'Cá sấu', 'polo_b.jpg', N'Áo Polo lịch lãm, form dáng chuẩn men.'),
(3, 1, N'Áo Thun In Họa Tiết', 'ao-thun-hoa-tiet', N'Cotton pha', 'tshirt_print.jpg', N'Phong cách trẻ trung, năng động.'),
(16, 1, N'Áo Sơ Mi Nam Trắng', 'ao-so-mi-nam-trang', N'Kate', 'somi_trang.jpg', N'Áo sơ mi trắng lịch lãm, phù hợp công sở và dự tiệc.'),

(4, 2, N'Quần Jean Slimfit', 'quan-jean-slimfit', N'Denim', 'jean_slim.jpg', N'Jean dáng ôm co giãn, tôn dáng.'),
(17, 2, N'Quần Kaki Nam', 'quan-kaki-nam', N'Kaki', 'kaki_nam.jpg', N'Quần kaki ống đứng, chất vải dày dặn, bền màu.'),

(6, 3, N'Áo Khoác Bomber', 'ao-khoac-bomber', N'Vải gió', 'bomber.jpg', N'Áo khoác Bomber phong cách thể thao, giữ ấm tốt.'),

-- === NỮ (Category 4, 5, 6) ===
(7, 4, N'Đầm Hoa Nhí Vintage', 'dam-hoa-nhi', N'Voan', 'dam_hoa.jpg', N'Đầm phong cách vintage nhẹ nhàng, nữ tính.'),
(8, 4, N'Đầm Body Dự Tiệc', 'dam-body-tiec', N'Thun lạnh', 'dam_body.jpg', N'Đầm ôm body quyến rũ, tôn đường cong.'),
(9, 4, N'Chân Váy Xếp Ly', 'chan-vay-xep-ly', N'Tuyết mưa', 'skirt_black.jpg', N'Chân váy xếp ly dáng dài, dễ phối đồ.'),
(18, 4, N'Đầm Suông Dạo Phố', 'dam-suong-dao-pho', N'Lụa', 'dam_suong.jpg', N'Đầm suông nhẹ nhàng, thoáng mát cho ngày hè.'),

(10, 5, N'Áo Sơ Mi Lụa', 'ao-so-mi-lua', N'Lụa tơ tằm', 'somi_lua.jpg', N'Áo sơ mi lụa mềm mại, sang trọng, thoáng mát.'),
(11, 5, N'Áo Croptop Năng Động', 'ao-croptop', N'Cotton', 'croptop.jpg', N'Áo Croptop cá tính, hack dáng cực đỉnh.'),

(12, 6, N'Quần Jean Ống Rộng', 'quan-jean-ong-rong', N'Denim', 'jean_rong.jpg', N'Quần jean ống rộng trendy, che khuyết điểm tốt.'),
(5, 6, N'Quần Short Kaki', 'quan-short-kaki', N'Kaki', 'short_kaki.jpg', N'Quần short kaki nữ tính, thoải mái vận động.'),
-- === PHỤ KIỆN (Category 9, 10, 11, 12) ===
-- Lưu ý: Phải dùng ID 9, 10, 11, 12. Tuyệt đối không dùng 7, 8 (là của Trẻ em)
(13, 9, N'Mũ Lưỡi Trai NY', 'mu-luoi-trai', N'Kaki', 'hat_ny.jpg', N'Mũ lưỡi trai phong cách NY năng động.'),
(14, 10, N'Túi Tote Vải Canvas', 'tui-tote', N'Canvas', 'tote.jpg', N'Túi tote size lớn, đựng vừa laptop.'),
(15, 10, N'Túi Đeo Chéo Da', 'tui-deo-cheo', N'Da PU', 'bag_leather.jpg', N'Túi mini đeo chéo tiện lợi.'),
(19, 10, N'Túi Đeo Chéo Nữ', 'tui-deo-cheo-nu', N'Da Tổng Hợp', 'tui_nu.jpg', N'Túi đeo chéo nữ thời trang, nhỏ gọn.'),

-- (MỚI THÊM) Thắt lưng (Cat 11) & Tất (Cat 12)
(20, 11, N'Thắt Lưng Da Bò', 'that-lung-da-bo', N'Da Bò Thật', 'belt_leather.jpg', N'Thắt lưng nam da bò thật, đầu khóa kim loại sang trọng.'),
(21, 12, N'Set 5 Đôi Tất Cotton', 'set-5-tat-cotton', N'Cotton', 'socks_set.jpg', N'Set 5 đôi tất cotton cổ cao, thấm hút mồ hôi tốt.');

SET IDENTITY_INSERT [dbo].[Product] OFF;
GO

-- E. Variants (Biến thể: Size/Màu/Giá)
INSERT INTO ProductVariant (ProductId, SKU, Size, Color, Price)
VALUES
-- Nam
(1, 'TSM-001-L-WHITE', 'L', N'Trắng', 150000),
(2, 'TSM-002-M-BLACK', 'M', N'Đen', 250000),
(3, 'TSM-003-XL-GRAY', 'XL', N'Xám', 180000),
(16, 'SMM-001-L-WHITE', 'L', N'Trắng', 300000),
(4, 'JNM-001-30-BLUE', '30', N'Xanh Đậm', 450000),
(5, 'SHORT-01-31-BE', '31', N'Be', 220000),
(17, 'KKM-001-32-BLACK', '32', N'Đen', 350000),
(6, 'JKT-001-L-GREEN', 'L', N'Rêu', 550000),
-- Nữ
(7, 'DRS-001-M-PINK', 'M', N'Hồng Nhạt', 350000),
(8, 'DRS-002-S-RED', 'S', N'Đỏ', 420000),
(9, 'DRS-003-FREE-BLACK', 'Free', N'Đen', 280000),
(18, 'DRS-004-M-YELLOW', 'M', N'Vàng', 280000),
(10, 'TPW-001-M-WHITE', 'M', N'Trắng Kem', 320000),
(11, 'TPW-002-S-PURPLE', 'S', N'Tím Pastel', 150000),
(12, 'JNW-001-28-LBLUE', '28', N'Xanh Nhạt', 380000),
-- Phụ kiện
(13, 'HAT-001-FREE-BLACK', 'Free', N'Đen', 120000),
(14, 'BAG-001-L-BE', 'Lớn', N'Be', 90000),
(15, 'BAG-002-S-BROWN', 'Nhỏ', N'Nâu', 250000),
(19, 'BAG-003-M-PINK', 'Trung', N'Hồng', 180000),
(20, 'BLT-001-FREE-BLACK', 'Free', N'Đen', 290000), 
(21, 'SCK-001-FREE-MULTI', 'Free', N'Nhiều màu', 85000);
GO

-- F. Stock (Kho)
INSERT INTO ProductVariantStock (VariantId, Stock)
SELECT VariantId, 50 FROM ProductVariant;
GO

-- G. Address & Order (Dữ liệu khách hàng mẫu)
INSERT [dbo].[CustomerAddress] ([UserId], [Line1], [Ward], [District], [Province], [Note]) 
VALUES (2, N'45 Lê Lợi', N'P.Bến Nghé', N'Q.1', N'TP.HCM', N'Giao giờ hành chính');
GO

SET IDENTITY_INSERT [dbo].[Order] ON;
INSERT [dbo].[Order] ([OrderId], [UserId], [CustomerName], [Phone], [AddressLine], [Note], [Status], [TotalAmount]) 
VALUES 
(1, 2, N'Nguyễn Văn A', N'0901234567', N'45 Lê Lợi, Q1, HCM', N'Giao nhanh giúp em', N'New', 670000);
SET IDENTITY_INSERT [dbo].[Order] OFF;

INSERT [dbo].[OrderItem] ([OrderId], [ProductId], [ProductName], [Quantity], [UnitPrice], [Note]) 
VALUES 
(1, 4, N'Quần Jean Slimfit', 1, 450000, N'Size 30'),
(1, 5, N'Quần Short Kaki', 1, 220000, N'Màu Be');
GO

-- H. HÌNH ẢNH SẢN PHẨM (IMAGES)
SET IDENTITY_INSERT [dbo].[ProductImage] ON;
GO

-- 1. Áo Thun Basic Trắng
INSERT [dbo].[ProductImage] ([ImageId], [ProductId], [ImageUrl]) VALUES (1, 1, N'ts_white_back.jpg'); 
INSERT [dbo].[ProductImage] ([ImageId], [ProductId], [ImageUrl]) VALUES (2, 1, N'ts_white_side.jpg'); 
-- 2. Áo Polo Nam Đen
INSERT [dbo].[ProductImage] ([ImageId], [ProductId], [ImageUrl]) VALUES (4, 2, N'polo_b_back.jpg');
INSERT [dbo].[ProductImage] ([ImageId], [ProductId], [ImageUrl]) VALUES (5, 2, N'polo_b_collar.jpg'); 
-- 4. Quần Jean Slimfit
INSERT [dbo].[ProductImage] ([ImageId], [ProductId], [ImageUrl]) VALUES (6, 4, N'jean_slim_back.jpg');
INSERT [dbo].[ProductImage] ([ImageId], [ProductId], [ImageUrl]) VALUES (7, 4, N'jean_slim_pocket.jpg');
-- 5. Quần Short Kaki
INSERT [dbo].[ProductImage] ([ImageId], [ProductId], [ImageUrl]) VALUES (9, 5, N'hinhphu_short_1.jpg');
INSERT [dbo].[ProductImage] ([ImageId], [ProductId], [ImageUrl]) VALUES (10, 5, N'hinhphu_short_2.jpg');
-- 7. Đầm Hoa Nhí Vintage
INSERT [dbo].[ProductImage] ([ImageId], [ProductId], [ImageUrl]) VALUES (12, 7, N'dam_hoa_sau.jpg');
INSERT [dbo].[ProductImage] ([ImageId], [ProductId], [ImageUrl]) VALUES (13, 7, N'dam_hoa_can.jpg');
-- 8. Đầm Body Dự Tiệc
INSERT [dbo].[ProductImage] ([ImageId], [ProductId], [ImageUrl]) VALUES (15, 8, N'dam_body_sau.jpg');
INSERT [dbo].[ProductImage] ([ImageId], [ProductId], [ImageUrl]) VALUES (16, 8, N'dam_body_nghieng.jpg');
-- 9. Chân Váy Xếp Ly
INSERT [dbo].[ProductImage] ([ImageId], [ProductId], [ImageUrl]) VALUES (29, 9, N'skirt_black1.jpg');
INSERT [dbo].[ProductImage] ([ImageId], [ProductId], [ImageUrl]) VALUES (30, 9, N'skirt_black2.jpg');
-- 10. Áo Sơ Mi Lụa
INSERT [dbo].[ProductImage] ([ImageId], [ProductId], [ImageUrl]) VALUES (17, 10, N'somi_lua_detail.jpg');
INSERT [dbo].[ProductImage] ([ImageId], [ProductId], [ImageUrl]) VALUES (18, 10, N'somi_lua_back.jpg');
-- 11. Áo Croptop Năng Động
INSERT [dbo].[ProductImage] ([ImageId], [ProductId], [ImageUrl]) VALUES (19, 11, N'hinhphu_crop_1.jpg');
INSERT [dbo].[ProductImage] ([ImageId], [ProductId], [ImageUrl]) VALUES (20, 11, N'hinhphu_crop_2.jpg');
-- 12. Quần Jean Ống Rộng
INSERT [dbo].[ProductImage] ([ImageId], [ProductId], [ImageUrl]) VALUES (27, 12, N'jean_1.jpg');
INSERT [dbo].[ProductImage] ([ImageId], [ProductId], [ImageUrl]) VALUES (28, 12, N'jean_2.jpg');
-- 13. Mũ Lưỡi Trai NY
INSERT [dbo].[ProductImage] ([ImageId], [ProductId], [ImageUrl]) VALUES (23, 13, N'hat_ny_back.jpg');
INSERT [dbo].[ProductImage] ([ImageId], [ProductId], [ImageUrl]) VALUES (24, 13, N'hat_ny_side.jpg');
-- 14. Túi Tote Canvas
INSERT [dbo].[ProductImage] ([ImageId], [ProductId], [ImageUrl]) VALUES (25, 14, N'tote_inside.jpg'); 
INSERT [dbo].[ProductImage] ([ImageId], [ProductId], [ImageUrl]) VALUES (26, 14, N'tote_model.jpg');
INSERT [dbo].[ProductImage] ([ImageId], [ProductId], [ImageUrl]) VALUES (31, 14, N'bag_leatherq1.jpg');
INSERT [dbo].[ProductImage] ([ImageId], [ProductId], [ImageUrl]) VALUES (32, 14, N'bag_leather2.jpg');
-- 16. Áo Sơ Mi Nam Trắng
INSERT [dbo].[ProductImage] ([ImageId], [ProductId], [ImageUrl]) VALUES (33, 16, N'somi_trang_detail.jpg');
INSERT [dbo].[ProductImage] ([ImageId], [ProductId], [ImageUrl]) VALUES (34, 16, N'somi_trang_back.jpg');
-- 17. Quần Kaki Nam
INSERT [dbo].[ProductImage] ([ImageId], [ProductId], [ImageUrl]) VALUES (35, 17, N'kaki_nam_detail.jpg');
INSERT [dbo].[ProductImage] ([ImageId], [ProductId], [ImageUrl]) VALUES (36, 17, N'kaki_nam_back.jpg');
-- 18. Đầm Suông
INSERT [dbo].[ProductImage] ([ImageId], [ProductId], [ImageUrl]) VALUES (37, 18, N'dam_suong_detail.jpg');
INSERT [dbo].[ProductImage] ([ImageId], [ProductId], [ImageUrl]) VALUES (38, 18, N'dam_suong_back.jpg');
-- 19. Túi Đeo Chéo Nữ
INSERT [dbo].[ProductImage] ([ImageId], [ProductId], [ImageUrl]) VALUES (39, 19, N'tui_nu_detail.jpg');
INSERT [dbo].[ProductImage] ([ImageId], [ProductId], [ImageUrl]) VALUES (40, 19, N'tui_nu_model.jpg');

-- (MỚI) 20. Thắt lưng Da Bò
INSERT [dbo].[ProductImage] ([ImageId], [ProductId], [ImageUrl]) VALUES (41, 20, N'belt_detail.jpg');
INSERT [dbo].[ProductImage] ([ImageId], [ProductId], [ImageUrl]) VALUES (42, 20, N'belt_box.jpg');
-- (MỚI) 21. Set Tất Cotton
INSERT [dbo].[ProductImage] ([ImageId], [ProductId], [ImageUrl]) VALUES (43, 21, N'socks_1.jpg');
INSERT [dbo].[ProductImage] ([ImageId], [ProductId], [ImageUrl]) VALUES (44, 21, N'socks_2.jpg');

SET IDENTITY_INSERT [dbo].[ProductImage] OFF;
GO
-- 4. Kiểm tra lại dữ liệu
--SELECT * FROM [dbo].[ProductImage];
GO
SELECT 'AppUser' AS TableName, * FROM AppUser;
SELECT 'CategoryGroup' AS TableName, * FROM CategoryGroup;
SELECT 'Category' AS TableName, * FROM Category;
SELECT 'Product' AS TableName, * FROM Product;
SELECT 'ProductImage' AS TableName, * FROM ProductImage;
SELECT 'ProductVariant' AS TableName, * FROM ProductVariant;
SELECT 'ProductVariantStock' AS TableName, * FROM ProductVariantStock;
SELECT 'CustomerAddress' AS TableName, * FROM CustomerAddress;
SELECT 'Order' AS TableName, * FROM [Order];
SELECT 'OrderItem' AS TableName, * FROM OrderItem;
