import { getCategoryDetail, getCategorietList, createCategorie, deleteCategorie } from "./Services/categoryServices.js"

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

window.handleSave = async () => {
    const catName = document.getElementById('catName').value;
    const catSlug = document.getElementById('catSlug').value;
    const description = document.getElementById('description').value;
    const groupId = document.getElementById('groupId').value; 

    if (!catName || !catSlug) {
        Swal.fire('Lỗi', 'Vui lòng điền đầy đủ thông tin!', 'error');
        return;
    }

    const data = {
        CatName: catName,
        CatSlug: catSlug,
        Description: description,
        GroupId: parseInt(groupId) 
    };

    console.log("Data gửi đi:", data); 

    const result = await createCategorie(data);

    if (result) {
        const modalElement = document.getElementById('categoryModal');
        const modalInstance = bootstrap.Modal.getInstance(modalElement) || new bootstrap.Modal(modalElement);
        modalInstance.hide();

        onReload();

        document.getElementById('formCategory').reset();

        Swal.fire({
            position: "center",
            icon: "success",
            title: "Thêm mới thành công!",
            showConfirmButton: false,
            timer: 1500
        });
    } else {
        Swal.fire('Thất bại', 'Lỗi Server (kiểm tra lại GroupId hoặc dữ liệu nhập)', 'error');
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

