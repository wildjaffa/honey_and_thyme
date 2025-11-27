import { useNavigate } from "react-router";
import { HoneyButton } from "../../components";

function AdminIndex() {
  const navigate = useNavigate();
  return (
    <div className="grid w-full justify-center space-y-3">
      <div></div>
      <HoneyButton onClick={() => navigate("/Admin/Albums")}>
        Albums
      </HoneyButton>
      <HoneyButton onClick={() => navigate("/Admin/PhotoShoots")}>
        Photo Shoots
      </HoneyButton>
      <HoneyButton onClick={() => navigate("/Admin/Products")}>
        Products
      </HoneyButton>
      <HoneyButton onClick={() => navigate("/Admin/Emails")}>
        Email Records
      </HoneyButton>
      <HoneyButton onClick={() => navigate("/available-appointments")}>
        Upcoming Appointments
      </HoneyButton>
      <div className="im-fell-english text-center">Site Version 2.0.0</div>
    </div>
  );
}

export default AdminIndex;
