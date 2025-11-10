import { getAuth, onAuthStateChanged } from "firebase/auth";
import type { User } from "firebase/auth";
import { useState, useEffect } from "react";
import "../firebase";

const auth = getAuth();

function useAuth() {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (user) => {
      setUser(user);
      setLoading(false);
      if (!user) return;
      user.getIdToken().then((token) => {
        localStorage.setItem("bearerToken", token);
      });
    });

    // Cleanup subscription on unmount
    return () => unsubscribe();
  }, []);

  return { user, loading };
}

export default useAuth;
