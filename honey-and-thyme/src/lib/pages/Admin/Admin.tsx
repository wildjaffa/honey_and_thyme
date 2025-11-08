import { Routes, Route } from "react-router";
import AdminIndex from "./AdminIndex";

function Admin() {
    return (
        <Routes >
            <Route path="/" element={<AdminIndex />}/>
        </Routes>
    )
}
export default Admin;