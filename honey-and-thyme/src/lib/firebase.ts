import { initializeApp, type FirebaseOptions } from "firebase/app";

const firebaseConfig: FirebaseOptions = {
  apiKey: "AIzaSyDYX7RhBqUUmVtzjYL2zRPPXuRBH6f2Juo",
  appId: "1:332065640580:web:4d425333b2308f9f85b2d1",
  messagingSenderId: "332065640580",
  projectId: "honey-and-thyme",
  authDomain: "honey-and-thyme.firebaseapp.com",
  storageBucket: "honey-and-thyme.appspot.com",
};

export const app = initializeApp(firebaseConfig);
