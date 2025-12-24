import { getCategoryDetail, getCategorietList, createCategorie, deleteCategorie, editCategorie } from "./Services/categoryServices.js"

const category = document.querySelector("#categorys");

const onReload = () => {
    fetchAPI();
}
const deleteItem = async (id) => {
    const result = await deleteCategorie(id);
    if (result) {
        onReload();
        Swal.fire({
            title: "Deleted!",
            text: "Your file has been deleted.",
            icon: "success"
        })
        
    }
}

window.handleDelete = (id) => {
    Swal.fire({
        title: "Are you sure?",
        text: "You won't be able to revert this!",
        icon: "warning",
        showCancelButton: true,
        confirmButtonColor: "#3085d6",
        cancelButtonColor: "#d33",
        confirmButtonText: "Yes, delete it!"
    }).then((result) => {
        if (result.isConfirmed) {
            deleteItem(id)
        }
    });
}

window.handleEdit = async (id) => {
    // 1. Lấy dữ liệu
    const item = await getCategoryDetail(id);

    if (!item) return;

    // 2. Đổ dữ liệu
    document.getElementById('hiddenId').value = item.CategoryId;
    document.getElementById('catName').value = item.CatName;
    document.getElementById('catSlug').value = item.CatSlug;
    document.getElementById('description').value = item.Description || "";
    document.getElementById('groupId').value = item.GroupId;

    document.querySelector('.modal-title').innerText = "Cập nhật danh mục";

    // 3. Mở Modal bằng JS (Để đảm bảo có dữ liệu rồi mới hiện)
    const modalElement = document.getElementById('categoryModal');
    const modalInstance = bootstrap.Modal.getInstance(modalElement) || new bootstrap.Modal(modalElement);
    modalInstance.show();
}

window.handleSave = async () => {
    const id = document.getElementById('hiddenId').value;
    const catName = document.getElementById('catName').value;
    const catSlug = document.getElementById('catSlug').value;
    const description = document.getElementById('description').value;
    const groupId = document.getElementById('groupId').value;

    let data;

    let result = false;

    if (id) {
        data = {
            CategoryId: id, 
            CatName: catName,
            CatSlug: catSlug,
            Description: description,
            GroupId: parseInt(groupId), 
            SortOrder: 1,
            IsActive: true,
            CreatedAt: "2025/12/24" 
        };
        result = await editCategorie(id, data);
    } else {
        data = {
            CatName: catName,
            CatSlug: catSlug,
            Description: description,
            GroupId: parseInt(groupId), 
            SortOrder: 1,
            IsActive: true,
            CreatedAt: "2025/12/24" 
        };
        result = await createCategorie(data);
    }

    if (result) {
        const modalElement = document.getElementById('categoryModal');
        const modalInstance = bootstrap.Modal.getInstance(modalElement) || new bootstrap.Modal(modalElement);
        modalInstance.hide();

        onReload();

        // Reset form sạch sẽ
        document.getElementById('formCategory').reset();
        document.getElementById('hiddenId').value = "";

        Swal.fire({
            icon: "success",
            title: id ? "Cập nhật thành công!" : "Thêm mới thành công!",
            timer: 1500,
            showConfirmButton: false
        });
    } else {
        Swal.fire('Thất bại', 'Lỗi Server (Kiểm tra lại dữ liệu)', 'error');
    }
}


const fetchAPI = async () => {
    const result = await getCategorietList();
    let htmls = await result.map(item => {
        return `
        <tr>
            <td class="fw-bold text-primary">
                ${item.GroupId}
            </td>
            <td class="fw-bold text-primary">
                ${item.CatSlug}
            </td>
            <td class="fw-bold text-primary">
                ${item.CatName}
            </td>
            <td class="fw-bold text-primary">
                ${item.Description}
            </td>
            <td class="text-center">
                <div class="btn-group" role="group">
                    <a href="#" onclick="handleEdit(${item.CategoryId})" type="button" class="btn btn-sm btn-warning" title="Sửa" data-bs-toggle="modal" data-bs-target="#categoryModal" >
                        Sửa
                    </a>
                    
                    <a href="#" onclick="handleDelete(${item.CategoryId})" class="btn btn-sm btn-danger" title="Xóa" >
                        Xóa
                    </a>
                </div>
            </td>
        </tr>
      `
    });
    category.innerHTML = htmls.join("");

    console.log(result);
}

fetchAPI();

