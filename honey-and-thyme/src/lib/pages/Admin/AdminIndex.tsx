import { useNavigate } from "react-router";
import { HoneyButton } from "../../components";

function AdminIndex() {

    const navigate = useNavigate();
    return (<><div>Admin Index!</div><HoneyButton onClick={() => navigate("/Admin/Album-Index")} >Albums</HoneyButton></>);
}

export default AdminIndex