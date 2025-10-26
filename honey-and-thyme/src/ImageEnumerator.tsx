import createFetchClient from "openapi-fetch";
import createClient from "openapi-react-query";
import type { paths } from "./lib/api/v1";

const fetchClient = createFetchClient<paths>({
    baseUrl: import.meta.env.VITE_BASE_URL,
});

const $api = createClient(fetchClient);

function ImageEnumerator() {


    const { data, error, isLoading } = $api.useQuery("get", "/albums/{id}", { params: { path: { id: "site-images" } } });


    return (
        <>{isLoading ? (
            <p>Loading album...</p>
        ) : error ? (
            <p>Error loading album: {String(error)}</p>
        ) : data ? (
            <div>
                <h2>Album: {data.name}</h2>
                <ul>
                    {data.images?.map((photo) => (
                        <li key={photo.imageId}>{photo.fileName}</li>
                    ))}
                </ul>
            </div>
        ) : null}</>
    )
}

export default ImageEnumerator;