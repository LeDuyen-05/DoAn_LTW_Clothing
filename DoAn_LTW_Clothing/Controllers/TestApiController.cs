using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace DoAn_LTW_Clothing.Controllers
{
    public class TestApiController : ApiController
    {
        [HttpGet]
        public IEnumerable<string> Get()
        {
            return new string[] { "Kết nối API thành công!", "Chào mừng đến với ColoShop" };
        }
    }
}
