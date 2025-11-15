import { Routes, Route } from "react-router";
import AdminIndex from "./AdminIndex";
import { getAuth, GoogleAuthProvider, signInWithPopup } from "firebase/auth";
import useAuth from "../../hooks/useAuth";
import { HoneyButton } from "../../components";
import AlbumIndex from "./Albums/AlbumIndex";
import AlbumImageManagement from "./Albums/AlbumImageManagement";

function Admin() {
  const { user, loading } = useAuth();
  const auth = getAuth();

  const handleGoogleSignIn = async () => {
    try {
      const provider = new GoogleAuthProvider();
      provider.addScope("https://www.googleapis.com/auth/contacts.readonly");
      await signInWithPopup(auth, provider);
    } catch (error) {
      console.error("Error signing in with Google:", error);
    }
  };

  if (loading) {
    return <div>Loading...</div>;
  }

  if (!user) {
    return (
      <div
        style={{
          display: "flex",
          justifyContent: "center",
          alignItems: "center",
          height: "100vh",
        }}
      >
        <HoneyButton onClick={handleGoogleSignIn}>
          Sign in with Google
        </HoneyButton>
      </div>
    );
  }

  return (
    <Routes>
      <Route path="/" element={<AdminIndex />} />
      <Route path="/Albums/:albumId" element={<AlbumImageManagement />} />
      <Route path="/Albums" element={<AlbumIndex />} />
      <Route path="/Products" element={<AlbumIndex />} />
      <Route path="/Albums" element={<AlbumIndex />} />
    </Routes>
  );
}

export default Admin;
