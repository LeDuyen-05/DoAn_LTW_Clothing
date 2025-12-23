using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace DoAn_LTW_Clothing.Models
{
    public class CategoryModel
    {
        public int CategoryId { get; set; }
        public int GroupId { get; set; }
        public string CatSlug { get; set; }
        public string CatName { get; set; }
        public string Description { get; set; }
        public int SortOrder { get; set; }
        public bool IsActive { get; set; }
        public Nullable<System.DateTime> CreatedAt { get; set; }
    }
}